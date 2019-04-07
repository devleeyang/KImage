//
//  NetworkManamger.swift
//  STUnitas
//
//  Created by 양혜리 on 07/04/2019.
//  Copyright © 2019 양혜리. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    func getImage(query: String, page: String, completion: @escaping ([ImageInfo]) -> Void) {
        if let encodeString = query.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed) {
            print(encodeString)
            get(path: "v2/search/image?query=\(encodeString)&page=\(page)") { (data) in
                if let imageResponse = try? JSONDecoder().decode(SearchImageInfo.self, from: data) {
                    let imageList = imageResponse.documents.map { image -> ImageInfo in
                        return ImageInfo(imageURL: image.imageURL, height: image.height, width: image.width)
                    }
                    completion(imageList)
                }
            }
        }
    }
    
    private func get(path: String, completion: @escaping (Data) -> Void) {
        let header = [ "Authorization": "KakaoAK c1ea3703b4cb2cc13679a01b3df453dd",
                       "content-type": "application/json" ]
        
        Alamofire.request("https://dapi.kakao.com/\(path)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON {
            guard let responseData = $0.data else {
                return
            }
            switch $0.result {
            case .success:
                completion(responseData)
            case .failure:
                break
            }
        }
    }
}
