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
    func getImage(query: String, page: String, onSuccess: @escaping ([ImageInfo]) -> Void, onFailure: @escaping (SearchError) -> Void) {
        if let encodeString = query.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed) {
            get(path: "v2/search/image?query=\(encodeString)&page=\(page)", onSuccess: { (data) in
                do {
                    let imageResponse = try JSONDecoder().decode(SearchImageInfo.self, from: data)
                    let imageList = imageResponse.documents.map { image -> ImageInfo in
                        return ImageInfo(imageURL: image.imageURL, height: image.height, width: image.width)
                    }
                    guard imageList.count != 0 else {
                        return onFailure(SearchError.notDecoder("이미지 정보를 찾을 수 없습니다."))
                    }
                    onSuccess(imageList)
                } catch {
                    onFailure(SearchError.notDecoder("이미지 정보를 찾을 수 없습니다."))
                }
            }, onFailure: {
                onFailure($0)
            })
        }
    }
    
    private func get(path: String, onSuccess: @escaping (Data) -> Void, onFailure: @escaping (SearchError) -> Void) {
        let header = [ "Authorization": "KakaoAK c1ea3703b4cb2cc13679a01b3df453dd",
                       "content-type": "application/json" ]
        
        Alamofire.request("https://dapi.kakao.com/\(path)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON {
            guard let responseData = $0.data else {
                return
            }
            switch $0.result {
            case .success:
                onSuccess(responseData)
            case let .failure(error):
                guard (error as NSError).code != -999 else {
                    onFailure(SearchError.cancel("개발자 취소"))
                    return
                }
                onFailure(SearchError.notFound("서버연결이 되지 않습니다."))
            }
        }
    }
}
