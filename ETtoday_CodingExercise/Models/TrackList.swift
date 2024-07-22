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
    init() {
        self.resultCount = 0
        self.results = []
    }
}
