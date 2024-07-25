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
    private var preSearchText = "" // Previous search text, use to determine the fetch mode
    private var fetchMode = FetchMode.newFetch // Indicates the current fetch is new or continue
    private var isFetching = false // Indicates if there's a fetch ongoing
    private var fetchedAll = false // Indicates if there's more data need to fetch
    
    var trackListData = ObservableObject(TrackList())
    
    func fetchTrackData(searchTerm: String, limitTo: Int = 25) {
        // Different searchTerm and empty searchTerm cancel previous request and reset trackListData
        if searchTerm != preSearchText || searchTerm == "" {
            startNewFetch(with: searchTerm)
        } else {
            continueFetch()
            // Make sure there's no ongoing fetch else abort same request
            guard isFetching == false && fetchedAll == false else { return }
        }
        
        guard let inputURL = urlSafeConstruct.constructURL(searchTerm: searchTerm, startFrom: trackListData.value.resultCount, limitTo: limitTo) else {
            print("inputURL error")
            // Show an error popup
            return
        }
        
        // Start fetching process
        isFetching = true
        network.fetch(fromURL: inputURL) { fetchedResponse in
            self.network.decode(fetchedResponse) { decodedResponse in
                let newResponse: TrackList = decodedResponse
                
                if self.fetchAllIsCompleted(with: newResponse) {
                    self.fetchedAll = true
                } else {
                    // More data need to fetch append current batch of tracks to track list
                    self.trackListData.value = TrackList(resultCount: self.trackListData.value.resultCount + newResponse.resultCount, results: self.trackListData.value.results + newResponse.results)
                }
                self.isFetching = false
            }
        }
    }
    
    private func startNewFetch(with searchTerm: String) {
        network.cancel()
        isFetching = false
        fetchMode = .newFetch
        fetchedAll = false
        trackListData.value = TrackList()
        preSearchText = searchTerm
    }
    
    private func continueFetch() {
        fetchMode = .continueFetch
    }
    
    private func fetchAllIsCompleted(with response: TrackList) -> Bool {
        return response.resultCount == 0
    }
    
    func currentFetchMode() -> FetchMode {
        return fetchMode
    }
    
    func finishedFetchingAllTracks() -> Bool {
        return fetchedAll
    }
}
