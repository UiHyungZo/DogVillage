//
//  ImageUploader.swift
//  MVPInstagram
//
//  Created by Mac on 2022/06/23.
//

import FirebaseStorage
import UIKit

struct ImageUploader{
    /*
     param : UIImage
     Param : @escaping -> Void
     Firebase에 strong에 이미지 등록
     */
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void){
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_image/\(filename)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error{
                print("DEBEG : Failed to upload image \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL{ (url, error) in
                guard let imageUrl = url?.absoluteString else {return}
                completion(imageUrl)
            }
            
        }
        
    }
    
    
    
}
