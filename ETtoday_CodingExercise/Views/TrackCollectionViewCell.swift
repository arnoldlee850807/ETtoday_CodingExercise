//
//  TrackCollectionViewCell.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit
import SnapKit

class TrackCollectionViewCell: UICollectionViewCell {
    private let imageCache = ImageCache()
    
    private var trackName = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        $0.text = ""
        $0.numberOfLines = 2
    }
    
    private var trackImageView = UIImageView {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 3
    }
    
    private var trackTime = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        $0.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
}

extension TrackCollectionViewCell {
    private func viewSetup() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(trackName)
        
        contentView.addSubview(trackImageView)
        
        contentView.addSubview(trackTime)
    }
    
    public func cellSetup(track: Track) {
        trackImageView.loadImage(imageCache: imageCache, imageURL: track.artworkUrl100)
        trackName.text = track.trackName
        trackTime.text = DateComponentsFormatter().string(from: TimeInterval(track.trackTimeMillis/1000)) ?? ""
    }
}
