//
//  TrackListViewModel.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit
import Foundation

enum FetchMode {
    case continueFetch
    case newFetch
}

class TrackListViewModel {
    private let urlSafeConstruct = URLSafeConstruct()
    private let network = NetworkService()
    private var preSearchText = ""
    private var fetchMode = FetchMode.newFetch
    private var isFetching = false
    
    var trackListData = ObservableObject(TrackList())
    
    func fetchTrackData(searchTerm: String, limitTo: Int = 25) {
        // Different searchTerm and empty searchTerm cancel previous request and reset trackListData
        if searchTerm != preSearchText || searchTerm == "" {
            network.cancel()
            resetTrackList()
            preSearchText = searchTerm
        } else {
            fetchMode = .continueFetch
            
            // Previous fetch in progress abort same request here
            if isFetching { return }
        }
        
        guard let inputURL = urlSafeConstruct.constructURL(searchTerm: searchTerm, startFrom: trackListData.value.resultCount, limitTo: limitTo) else {
            print("inputURL error")
            // Show an error popup
            return
        }
        isFetching = true
        
        network.fetch(fromURL: inputURL) { fetchedResponse in
            self.network.decode(fetchedResponse) { decodedResponse in
                let newResponse: TrackList = decodedResponse
                self.trackListData.value = TrackList(resultCount: self.trackListData.value.resultCount + newResponse.resultCount, results: self.trackListData.value.results + newResponse.results)
                self.isFetching = false
            }
        }
    }
    
    private func resetTrackList() {
        isFetching = false
        fetchMode = .newFetch
        trackListData.value = TrackList()
    }
    
    func currentFetchMode() -> FetchMode {
        return fetchMode
    }
}
