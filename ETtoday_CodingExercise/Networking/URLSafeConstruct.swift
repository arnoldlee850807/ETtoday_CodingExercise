//
//  URLSafeConstruct.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import Foundation

class URLSafeConstruct: NSObject {
    public func constructURL(searchTerm: String, startFrom: Int, limitTo: Int) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/search"
        let termQueryItem = URLQueryItem(name: "term", value: searchTerm)
        let startFromQueryItem = URLQueryItem(name: "offset", value: "\(startFrom)")
        let limitToQueryItem = URLQueryItem(name: "limit", value: "\(limitTo)")
        urlComponents.queryItems = [termQueryItem, startFromQueryItem, limitToQueryItem]
        return urlComponents.url?.absoluteURL
    }
}
