//
//  TrackList.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import Foundation

struct TrackList: Decodable {
    var resultCount: Int
    var results: [Track]
    init(resultCount: Int = 0, results: [Track] = []) {
        self.resultCount = resultCount
        self.results = results
    }
}
