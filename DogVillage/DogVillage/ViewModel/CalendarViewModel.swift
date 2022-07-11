//
//  CalendarViewModel.swift
//  DogVillage
//
//  Created by Mac on 2022/07/08.
//

import Foundation


struct CalendarViewModel{
    
    
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
    
    var timeStamp: String{
        var time = post.timestamp
        let regex = "^([2-3]{4})+-([1-2]{1,2})+-([1-3]{1,2})$"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        
        return ""
    }
    
}
