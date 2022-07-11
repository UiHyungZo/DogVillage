//
//  AuthService.swift
//  MVPInstagram
//
//  Created by Mac on 2022/06/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import RxSwift

struct AuthCredentials{
    let email:String
    let password:String
    let fullname:String
    let username:String
    let profileImage:UIImage
}


struct AuthService{
    /*
     param : AuthCredentials
     param : @escaping -> Void
     회원 등록
     */
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void){
        DispatchQueue.global().async {
            ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) {
                    (result, error) in
                 
                    if let error = error {
                        print("DEBUG: Failed to register user \(error.localizedDescription)")
                        completion(error)
                        return
                    }
                    
                    guard let uid = result?.user.uid else {return}
                    
                    let data: [String: Any] = ["email":credentials.email,
                                               "fullname":credentials.fullname,
                                               "profileImageUrl":imageUrl,
                                               "uid": uid,
                                               "username":credentials.username]//키 밸류 저장
                    DispatchQueue.main.async {
                        Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
                    }
                    
                    
                    
                }
            }
        }
        
    }
    /*
     param : email
     param : callBack
     로그인
     */
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?){
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    /*
     param : email
     param : ResetCallback
     비밀번호 재설정
     */
    static func resetPassword(withEmail email: String, completion: SendPasswordResetCallback?){
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    
    /*
     parma : email
     중복 이메일이 있는지 확인
     */
    static func emailDuplicate(withEmail restriId: String, completion:@escaping(Bool) -> ()){
        
        let query = COLLECTION_USERS.whereField("email", isEqualTo: restriId)
        
        query.addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot{
                let result = querySnapshot.isEmpty
                completion(result)
            }
        }
        
    }
    
    static func upDateUser(username : String, fullname : String, image : UIImage,completion: @escaping(FirestoreCompletion)){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ImageUploader.uploadImage(image: image) { imageUrl in
            COLLECTION_USERS.document(uid).updateData([
                "fullname":fullname,
                "profileImageUrl":imageUrl,
                "username":username
            ]){ error in
                if let error = error{
                    return
                }
            }
        }
    
    }
    
    static func deletaUser(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
       
        
        DispatchQueue.global().async {
            Auth.auth().currentUser?.delete(completion: { error in
                if let error = error{
                    return
                }
            })
            
            COLLECTION_USERS.document(uid).delete { error in
                if let error = error{
                    print("DEBUG: user delete \(error.localizedDescription)")
                    return
                }
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).addSnapshotListener(){(snapshot, error) in
                    
                    guard let documents = snapshot?.documents else {return}
                    
                    let docIDs = documents.map({$0.documentID})
                    
                    docIDs.forEach { document in
                        COLLECTION_POSTS.document(document).delete()
                    }
                    
                    
                }
                
                
            }
      
        }
        
    }
}



