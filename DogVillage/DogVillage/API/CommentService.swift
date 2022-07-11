//
//  CommentService.swift
//  DogVillage
//
//  Created by Mac on 2022/06/27.
//

import Firebase
import FirebaseStorage

struct CommentService{
    /*
     param : comment
     param : postID
     param : @escaping -> Void
     
     게시글에 댓글 남기기
     */
    static func uploadComment(comment: String, postID: String, user: User, completion: @escaping(FirestoreCompletion)){
        
        DispatchQueue.global().async {
            let data: [String: Any] = ["uid":user.uid,
                                       "comment":comment,
                                       "timestamp": Timestamp(date: Date()),
                                       "username":user.username,
                                       "profileImageUrl":user.profileImageUrl]
            
            COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data, completion: completion)
        }
        
        
    }
    
    /*
     param : postID
     param : @escaping -> void
     해당 게시글에 댓글 보여주기
     */
    
    static func fetchComments(forPost postID: String, completion: @escaping([Comment]) -> Void){
        
        DispatchQueue.global().async {
            var comments = [Comment]()
            let query = COLLECTION_POSTS.document(postID).collection("comments").order(by: "timestamp",descending: true)
            
            query.addSnapshotListener{ (snapshot, error) in
                snapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let comment = Comment(dictionary: data)
                        comments.append(comment)
                    }
                })
                DispatchQueue.main.async {
                    completion(comments)
                }
                
            }
        }
        
    }
}
