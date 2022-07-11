//
//  PostViewModel.swift
//  DogVillage
//
//  Created by Mac on 2022/06/27.
//


import UIKit
import RxSwift
import RxRelay
import Firebase
import FirebaseFirestore


struct PostViewModel{
    
    
    
    var post: Post
    

    
    init(post: Post){
        self.post = post
        
    }
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var caption: String{
        return post.caption
    }
    
    var likes: Int{
        return post.likes
    }
    
    var userProfileImageUrl: URL? {return URL(string: post.ownerImageUrl)}
    
    var username: String {return post.ownerUsername}
    
    var likesLabelText: String{
        if post.likes != 1{
            return "\(post.likes) likes"
        }else{
            return "\(post.likes) like"
        }
    }
    
    var likeButtonTintColor: UIColor{
        return post.didLike ? .red: .black
    }
    
    var likeButtonImage: UIImage?{
        let imageName = post.didLike ? "like_selected":"like_unselected"
        return UIImage(named: imageName)
    }
    
    var timestampString: String?{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        
        return formatter.string(from: post.timestamp.dateValue(), to: Date())
    }
    
    var removeImage: String?{
        let imageName = post.currentUser ? "trash.fill":""
        return imageName
    }
    
    
    
    
}
