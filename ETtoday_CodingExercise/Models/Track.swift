//
//  Track.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import Foundation

struct Track: Decodable {
    let trackId: Int
    let trackName: String
    let trackTimeMillis: Int
    let artworkUrl100: URL
    let longDescription: String?
    let trackViewUrl: URL?
}
