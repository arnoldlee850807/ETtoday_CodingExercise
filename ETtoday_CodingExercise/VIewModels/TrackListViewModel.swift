//
//  TrackListViewModel.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit
import Foundation

class TrackListViewModel {
    private let urlSafeConstruct = URLSafeConstruct()
    private let network = NetworkService()
    
    var trackListData = ObservableObject(TrackList())
    
    func fetchTrackData(searchTerm: String, startFrom: Int = 0, limitTo: Int = 25) {
        guard let inputURL = urlSafeConstruct.constructURL(searchTerm: searchTerm, startFrom: startFrom, limitTo: limitTo) else {
            print("inputURL error")
            // Show an error popup
            return
        }
        network.fetch(fromURL: inputURL) { fetchedResponse in
            self.network.decode(fetchedResponse) { decodedResponse in
                let newResponse: TrackList = decodedResponse
                self.trackListData.value.resultCount += newResponse.resultCount
                self.trackListData.value.results += newResponse.results
            }
        }
    }
}
