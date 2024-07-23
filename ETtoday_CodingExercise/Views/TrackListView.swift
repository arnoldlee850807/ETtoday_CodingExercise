//
//  TrackListView.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit
import SnapKit

class TrackListView: UIViewController {
    
    private let viewModel = TrackListViewModel()
    private let urlSafeConstruct = URLSafeConstruct()
    private let network = NetworkService()
    
    private lazy var searchBar = UISearchBar {
        $0.delegate = self
        $0.placeholder = "Enter Keyword Here"
    }
    
    private lazy var noTrackUIlabel = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 35, weight: UIFont.Weight.semibold)
        $0.text = "Type something in the search bar to find tracks"
        $0.numberOfLines = 3
        $0.textAlignment = .center
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: "TrackCollectionViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        bindersSetup()
        
        // Testing use
        let urlSafeConstruct = URLSafeConstruct()
        guard let trackListURL = urlSafeConstruct.constructURL(searchTerm: "jason mars", startFrom: 0, limitTo: 1) else {
            print("trackListURL error")
            return
        }
        let network = NetworkService()
        network.fetch(fromURL: trackListURL) { fetchedResponse in
            network.decode(fetchedResponse) { decodedFetchedResponse in
                let d: TrackList = decodedFetchedResponse
                print(d)
            }
        }
    }
}

extension TrackListView {
    private func viewSetup() {
        title = "Search iTunes"
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(50)
        }
        
        view.addSubview(noTrackUIlabel)
        noTrackUIlabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.centerX.centerY.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindersSetup() {
    }
}

extension TrackListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.trackListData.value.resultCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2.5, bottom: 0, right: 2.5)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 15) / 2
        return CGSize(width: width , height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collectionCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15) {
            collectionCell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.15) {
                collectionCell?.transform = .identity
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let collectionCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15) {
            collectionCell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let collectionCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15) {
            collectionCell?.transform = .identity
        }
    }
}

extension TrackListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
