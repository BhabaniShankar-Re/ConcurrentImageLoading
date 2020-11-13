//
//  ImageResposeModel.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 23/08/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import Foundation

struct ImageResponse: Decodable {
    let total: Int
    let imageList: [PixaImage]
    
    enum CodingKeys: String, CodingKey {
        case total = "totalHits"
        case imageList = "hits"
    }
}
