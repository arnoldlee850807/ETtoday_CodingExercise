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
    private var footerView = LoadingFooterView()
    
    private lazy var searchBar = UISearchBar {
        $0.delegate = self
        $0.placeholder = "Enter Keyword Here"
        $0.barTintColor = .white
        $0.searchTextField.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        $0.searchTextField.textColor = .black
        $0.searchTextField.tintColor = .systemBlue
        $0.searchTextField.leftView?.tintColor = .gray
        $0.searchTextField.attributedPlaceholder = NSAttributedString(string: $0.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
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
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 2, left: 5, bottom: 0, right: 5)
        layout.footerReferenceSize = CGSize(width: view.frame.width, height: 50)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.reuseIdentifier)
        view.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingFooterView.reuseIdentifier)
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.isHidden = true
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 7
        view.color = .white
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
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
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(70)
        }
    }
    
    private func bindersSetup() {
        viewModel.trackListData.bind { _ in
            DispatchQueue.main.async {
                // Use insert to prevent collectionView flickering when fetching with the same term
                if self.viewModel.currentFetchMode() == .continueFetch {
                    
                    // Make sure there's new data coming in
                    guard self.collectionView.numberOfItems(inSection: 0) < self.viewModel.trackListData.value.resultCount else {
                        // No new data coming stop activity indicdator
                        self.footerView.stopAnimating()
                        return
                    }
                    
                    self.footerView.startAnimating()
                    var addedIndexPaths = [IndexPath]()
                    for i in self.collectionView.numberOfItems(inSection: 0)..<self.viewModel.trackListData.value.resultCount {
                        addedIndexPaths.append(IndexPath(row: i, section: 0))
                    }
                    self.collectionView.insertItems(at: addedIndexPaths)
                } else {
                    
                    // Track list count is 0 stop activity indicator, track list count > 0 start activity Indicator
                    self.viewModel.trackListData.value.resultCount == 0 ? self.footerView.stopAnimating():self.footerView.startAnimating()
                    
                    self.collectionView.reloadData()
                }
            }
        }
        
        viewModel.isFetching.bind { value in
            DispatchQueue.main.async {
                if self.collectionView.numberOfItems(inSection: 0) == 0 {
                    self.activityIndicator.isHidden = !value
                }
            }
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackCollectionViewCell ?? TrackCollectionViewCell()
        cell.cellSetup(track: viewModel.trackListData.value.results[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoadingFooterView.reuseIdentifier, for: indexPath) as! LoadingFooterView
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
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
        viewModel.fetchTrackData(searchTerm: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension TrackListView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        
        // Make sure collectionView is not empty and there's still tracks haven't been fetched
        guard collectionView.contentSize.height > 0.0 && viewModel.finishedFetchingAllTracks() == false else {
            footerView.stopAnimating()
            return
        }
        
        let collectionViewContentBottomOffset = scrollView.contentOffset.y + scrollView.frame.height
        // Auto fetch the next patch of the tracks when users scroll over 95% of the track list
        if collectionViewContentBottomOffset >= collectionView.contentSize.height * 0.95 {
            viewModel.fetchTrackData(searchTerm: searchBar.text ?? "")
        }
    }
}
