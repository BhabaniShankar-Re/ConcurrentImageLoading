//
//  PixaImageModel.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 23/08/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import UIKit
class PixaImage: Decodable {
    let authorName: String
    let authorImageUrl: String
    let imageUrl: String
    var authorImage: UIImage? = UIImage(named: "defaultuser")
    var image: UIImage? = UIImage(named: "placeholder")
    
    init(auther name: String, userUrl: String, imageUrl: String) {
        authorName = name
        authorImageUrl = userUrl
        self.imageUrl = imageUrl
    }
    enum CodingKeys: String, CodingKey {
        case authorName = "user"
        case authorImageUrl = "userImageURL"
        case imageUrl = "webformatURL"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.authorName = try container.decode(String.self, forKey: .authorName)
        self.authorImageUrl = try container.decode(String.self, forKey: .authorImageUrl)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
    
    
    
}
