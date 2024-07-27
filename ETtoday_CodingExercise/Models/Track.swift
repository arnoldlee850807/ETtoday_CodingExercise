//
//  Track.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import Foundation

struct Track: Decodable {
    // Genral
    let wrapperType: String?
    let previewUrl: URL?
    let artworkUrl100: URL?
    
    // Music and Movie Tracks
    let kind: String?
    let trackName: String?
    let trackTimeMillis: Int?
    let longDescription: String?
    
    // Audiobooks
    let collectionName: String?
    let description: String?
}
