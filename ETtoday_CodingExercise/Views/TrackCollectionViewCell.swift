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
    
    private let formatter = DateComponentsFormatter {
        $0.allowedUnits = [.minute, .second]
        $0.unitsStyle = .positional
        $0.zeroFormattingBehavior = .pad
    }
    
    private var trackName = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        $0.text = ""
        $0.numberOfLines = 2
    }
    
    private var trackImageView = UIImageView {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private var trackTime = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        $0.text = ""
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}

extension TrackCollectionViewCell {
    private func viewSetup() {
        contentView.backgroundColor = .green
        
        contentView.addSubview(trackImageView)
        trackImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.height.width.equalTo(100)
            $0.centerY.equalToSuperview()
        }
        
        contentView.addSubview(trackTime)
        trackTime.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalTo(trackImageView)
            $0.height.equalTo(15)
            $0.width.greaterThanOrEqualTo(50)
        }
        
        contentView.addSubview(trackName)
        trackName.backgroundColor = .red
        trackName.snp.makeConstraints {
            $0.centerY.equalTo(trackImageView)
            $0.leading.equalTo(trackImageView.snp.trailing).offset(20)
            $0.trailing.lessThanOrEqualTo(trackTime.snp.leading).offset(-10)
            $0.top.equalToSuperview().offset(50)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
    
    public func cellSetup(track: Track) {
        trackImageView.loadImage(imageCache: imageCache, imageURL: track.artworkUrl100)
        trackName.text = track.trackName
        trackTime.text = formatter.string(from: TimeInterval(track.trackTimeMillis/1000)) ?? ""
    }
}
