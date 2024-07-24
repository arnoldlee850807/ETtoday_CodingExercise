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
        layout.estimatedItemSize = CGSize(width: view.frame.width - 10, height: 200)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
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
        viewModel.trackListData.bind { _ in
            DispatchQueue.main.async {
                
                // Use insert to prevent collectionView flickering when fetching with the same term
                if self.viewModel.currentFetchMode() == .continueFetch {
                    var addedIndexPaths = [IndexPath]()
                    for i in self.collectionView.numberOfItems(inSection: 0)..<self.viewModel.trackListData.value.resultCount {
                        addedIndexPaths.append(IndexPath(row: i, section: 0))
                    }
                    self.collectionView.insertItems(at: addedIndexPaths)
                } else {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension TrackListView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.trackListData.value.resultCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCollectionViewCell", for: indexPath) as? TrackCollectionViewCell ?? TrackCollectionViewCell()
        cell.cellSetup(track: viewModel.trackListData.value.results[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collectionCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15) {
            collectionCell?.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.15) {
                collectionCell?.transform = .identity
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let collectionCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15) {
            collectionCell?.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
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
    
    // Every input change will trigger a fetch
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.fetchTrackData(searchTerm: searchText, limitTo: 25)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension TrackListView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        
        // Prevent auto fetch when there's no tracks fetched or the tracks fetched can't even fill up the page
        guard collectionView.contentSize.height > scrollView.frame.height else { return }
        
        
        let collectionViewContentBottomOffset = scrollView.contentOffset.y + scrollView.frame.height
        // Auto fetch the next patch of the tracks when users scroll over 80% of the track list
        if collectionViewContentBottomOffset >= collectionView.contentSize.height * 0.8 {
            viewModel.fetchTrackData(searchTerm: searchBar.text ?? "")
        }
    }
}
