//
//  ViewController.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlSafeConstruct = URLSafeConstruct()
        guard let getDessertListURL = urlSafeConstruct.constructURL(searchTerm: "jason mars", startFrom: 0, limitTo: 1) else {
            print("getDessertListURL error")
            return
        }
        let network = NetworkService()
        network.fetch(fromURL: getDessertListURL) { fetchedResponse in
            network.decode(fetchedResponse) { decodedFetchedResponse in
                let d: TrackList = decodedFetchedResponse
                print(d)
            }
        }
    }


}

