//
//  SearchError.swift
//  STUnitas
//
//  Created by 양혜리 on 07/04/2019.
//  Copyright © 2019 양혜리. All rights reserved.
//

import Foundation

enum SearchError: Error {
    case unknown(Error)
    case notFound(String)
    case notDecoder(String)
    case cancel(String)
}

extension SearchError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case let .unknown(error):
            return error.localizedDescription
        case let .notFound(x):
            return x
        case let .notDecoder(x):
            return x
        case let .cancel(x):
            return x
        }
    }
}
