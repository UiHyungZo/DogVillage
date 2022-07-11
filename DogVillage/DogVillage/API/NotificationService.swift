//
//  NotificationService.swift
//  DogVillage
//
//  Created by Mac on 2022/06/29.
//

import Firebase

struct NotificationService{
    /*
     param : uid
     param : fromUser
     param : NotificationType
     param : post
     
     post, 댓글 알람 등록하기
     */
    static func uploadNotification(toUid uid: String, fromUser: User, type: NotificationType, post: Post? = nil){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard uid != currentUid else {return}
        DispatchQueue.global().async {
            
            let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
            
            var data: [String: Any] = ["timestamp":Timestamp(date: Date()),
                                       "uid": currentUid,
                                       "type": type.rawValue,
                                       "id": docRef.documentID,
                                       "userProfileImageUrl": fromUser.profileImageUrl,
                                       "username": fromUser.username]
            
            if let post = post{
                data["postId"] = post.postId
                data["postImageUrl"] = post.imageUrl
            }
            
            docRef.setData(data)
        }
           
           
       }
    
    /*
     param : uid
     param : fromUser
     param : NotificationType
     팔로우한 상대에게 알람등록
     
     */
    static func uploadNotification(toUid uid: String, fromUser: User, type: NotificationType){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard uid != currentUid else {return}
        DispatchQueue.global().async {
            let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
            
            let data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                       "uid": fromUser.uid,
                                       "type": type.rawValue,
                                       "id": docRef.documentID,
                                       "userProfileImageUrl": fromUser.profileImageUrl,
                                       "username": fromUser.username]
            
            
            
            docRef.setData(data)
        }
        
        
    }
    /*
     param : @escaping -> Void
     알람 리스트 보여주기
     */
    
    static func fetchNotification(completion: @escaping([Notification]) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.global().async {
            let query = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").order(by: "timestamp",descending: true)
            
            query.getDocuments {
                snapshot, _ in
                guard let documents = snapshot?.documents else {return}
                let notifications = documents.map({ Notification(dictionary: $0.data()) })
                DispatchQueue.main.async {
                    completion(notifications)
                }
                
            }
        }
        
    }
    
    
}
