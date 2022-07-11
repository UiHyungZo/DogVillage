//
//  PostService.swift
//  DogVillage
//
//  Created by Mac on 2022/06/27.
//

import UIKit
import Firebase
import RxSwift

struct PostService{
    /*
     param : caption
     param : image
     param : @escaping -> Void
     게시글을 올릴 때 쓰는 로직
     
     */
    static func uploadPost(caption: String, image: UIImage, user: User ,completion: @escaping(FirestoreCompletion)){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        DispatchQueue.global().async {
            ImageUploader.uploadImage(image: image) { imageUrl in
                let data = ["caption": caption,
                            "timestamp": Timestamp(date: Date()),
                            "likes": 0,
                            "imageUrl": imageUrl,
                            "ownerUid": uid,
                            "ownerImageUrl": user.profileImageUrl,
                            "ownerUsername": user.username] as [String : Any]
                
                let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
                
                self.updateUserFeedAfterPost(postId: docRef.documentID)
            }
        
        }
        
    }
    /*
     param : @escaping -> Void
     Feed에다가 post를 나타내기 위한 로직
     */
    static func fetchPosts(completion: @escaping([Post]) -> Void){
        DispatchQueue.global().async {
            COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {return}
                
                let posts = documents.map({Post(postId: $0.documentID, dictionary: $0.data())})
                DispatchQueue.main.async {
                    completion(posts)
                }
                
            }
        }
        
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void){
        
        DispatchQueue.global().async {
            let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
            
            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {return}
                
                var posts = documents.map({Post(postId: $0.documentID, dictionary: $0.data())})
                
                posts.sort{(post1, post2) -> Bool in
                    return post1.timestamp.seconds > post2.timestamp.seconds }
                
                
                DispatchQueue.main.async {
                    completion(posts)
                }
                
            }
        }
        
        
    }
    
    
    

    /*
    static func fetchDatePost(forUser uid: String, selectCell selectDate: String, completion:@escaping([Post]) -> Void){
        
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        
        
        
        query.getDocuments { snapshot, error in
            
            guard let error = error else{
                print("DEBUG ; \(error?.localizedDescription)")
                return
            }
            
            
            
            
            guard let documents = snapshot?.documents else {return}
            
          
            
            var posts = documents.map({Post(postId: $0.documentID, dictionary: $0.data())})
            
            
            completion(posts)
        }
        
        
    }
    */
    
    
    /*
     param : postId
     param : @escaping -> Void
     여러가지 feed중에 한 가지를 선택하였을 때 가는 로직
     */
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void){
        DispatchQueue.global().async {
            COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
                guard let snapshot = snapshot else {return}
                guard let data = snapshot.data() else {return}
                let post = Post(postId: snapshot.documentID, dictionary: data)
                DispatchQueue.main.async {
                    completion(post)
                }
                
            }
        }
       
    }
    /*
     param : post
     parama : @escaping -> Void
     게시글에 좋아요를 하기 위한 로직
     */
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        DispatchQueue.global().async {
            COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
            
            COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]){
                _ in
                COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
            }
        }
       
    }
    /*
     param : post
     param : @escaping -> Void
     좋아요를 취속하기 위한 로직
     */
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard post.likes > 0 else {return}
        
        DispatchQueue.global().async {
            
            COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
            
            COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
                COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
            }
        }
        
    }
    /*
     param : post
     param : @escapgin -> Void
     게시글에 좋아요를 했는지 확인하기 위한 로직
     */
    static func checkIfUserLikedPost(post: Post, completion:@escaping(Bool) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        DispatchQueue.global().async {
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).getDocument { snapshot, _ in
                guard let didLike = snapshot?.exists else{return}
                completion(didLike)
            }
        }
      
    }
    /*
     param : user
     param : didFollow
     follow를 하면 feed에 나오고, unfollow하면 feed에 안나온다.
     */
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        DispatchQueue.global().async {
            let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
            query.getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {return}
                
                let docIDs = documents.map({$0.documentID})
                docIDs.forEach { id in
                    if didFollow{
                        COLLECTION_USERS.document(uid).collection("user-feed").document(id).setData([:])
                    }else{
                        COLLECTION_USERS.document(uid).collection("user-feed").document(id).delete()
                    }
                }
            }
        }
        
    }
    /*
     param : @escaping -> Void
     follow한 대상만 feed에 나타나기
     */
    static func fetchFeedPosts(completion: @escaping([Post]) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        var posts = [Post]()
        DispatchQueue.global().async {
            COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, error in
                snapshot?.documents.forEach({ document in
                    fetchPost(withPostId: document.documentID) { post in
                        posts.append(post)
                        
                        posts.sort(by: {$0.timestamp.seconds > $1.timestamp.seconds})
                        DispatchQueue.main.async {
                            completion(posts)
                        }
                        
                    }
                })
            }
        }
       
        
    }
    
    private static func updateUserFeedAfterPost(postId: String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {return}
            
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postId).setData([:])
            }
            
            COLLECTION_USERS.document(uid).collection("user-feed").document(postId).setData([:])
        }
    }
    
    static func removePost(postId: String, currentUser: String, completion:@escaping(FirestoreCompletion)){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        if currentUser == uid {
            COLLECTION_POSTS.document(postId).delete(){ error in
                
                guard let error = error else {return}
                
                print("DEBUG : remove success")
                
                
            }
        }
        
        
        
        
    }
    
    
}
