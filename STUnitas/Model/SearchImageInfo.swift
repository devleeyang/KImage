//
//  SearchImageInfo.swift
//  STUnitas
//
//  Created by 양혜리 on 07/04/2019.
//  Copyright © 2019 양혜리. All rights reserved.
//

import Foundation

struct SearchImageInfo: Codable {
    let documents: [Document]
}

struct Document: Codable {
    let height: Int
    let imageURL: String
    let width: Int
    
    enum CodingKeys: String, CodingKey {
        case height
        case imageURL = "image_url"
        case width
    }
}

struct ImageInfo {
    let imageURL: String
    let height: Int
    let width: Int
}
