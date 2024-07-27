//
//  TrackCollectionViewCell.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit
import SnapKit

class TrackCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "\(TrackCollectionViewCell.self)"
    private let imageCache = ImageCache()
    
    private let formatter = DateComponentsFormatter {
        $0.allowedUnits = [.minute, .second]
        $0.unitsStyle = .positional
        $0.zeroFormattingBehavior = .pad
    }
    
    private var trackType = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
        $0.text = ""
        $0.numberOfLines = 1
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
    
    private var trackDescription = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
        $0.numberOfLines = 0
    }
    
    private var trackDescriptionHeightConstraint: Constraint? = nil
    
    private var trackPlayerIndicator = UILabel {
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.bold)
        $0.text = ""
        $0.numberOfLines = 1
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .black
        view.startAnimating()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel current image fetch for cell reuse
        trackImageView.cancelLoadImage(in: imageCache)
        // Set current image to empty for cell reuse
        trackImageView.image = nil
        // Set current track status to initial for cell reuse
        trackPlayerIndicator.text = ""
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}

extension TrackCollectionViewCell {
    private func viewSetup() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.height.width.equalTo(100)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(30)
            $0.bottom.lessThanOrEqualToSuperview().inset(30)
        }
        
        contentView.addSubview(trackImageView)
        trackImageView.snp.makeConstraints {
            $0.edges.equalTo(activityIndicator)
        }
        
        contentView.addSubview(trackPlayerIndicator)
        trackPlayerIndicator.snp.makeConstraints {
            $0.centerX.equalTo(trackImageView)
            $0.top.equalTo(trackImageView.snp.bottom).offset(2)
            $0.height.equalTo(15)
        }
        
        contentView.addSubview(trackType)
        trackType.snp.makeConstraints {
            $0.leading.equalTo(trackImageView.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(trackTime)
        trackTime.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(15)
            $0.width.greaterThanOrEqualTo(50)
        }
        
        contentView.addSubview(trackName)
        trackName.snp.makeConstraints {
            $0.top.equalTo(trackType.snp.bottom).offset(5)
            $0.leading.equalTo(trackImageView.snp.trailing).offset(20)
            $0.trailing.lessThanOrEqualTo(trackTime.snp.leading).offset(-10)
            $0.centerY.equalTo(trackTime)
        }
        
        contentView.addSubview(trackDescription)
        trackDescription.snp.makeConstraints {
            $0.top.equalTo(trackName.snp.bottom).offset(10)
            $0.leading.equalTo(trackImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
            trackDescriptionHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        // Corner radius and shadow settings
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.cornerRadius = 3
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    public func cellSetup(track: Track) {
        trackImageView.loadImage(in: imageCache, imageURL: track.artworkUrl100 ?? URL(fileURLWithPath: ""))
        trackName.text = track.trackName == nil ? track.collectionName:track.trackName
        trackTime.text = track.trackTimeMillis == nil ? "":formatter.string(from: TimeInterval(track.trackTimeMillis!/1000))!
        trackType.text = track.kind == nil ? track.wrapperType:track.kind
        track.longDescription == nil && track.description == nil ? trackDescriptionHeightConstraint?.activate():trackDescriptionHeightConstraint?.deactivate()
        trackDescription.text = track.longDescription == nil ? track.description:track.longDescription
        layoutIfNeeded()
    }
    
    public func trackPlayerStatusChange(status: PlayerStatus) {
        switch status {
        case .finished, .initial:
            trackPlayerIndicator.text = ""
        case .paused:
            trackPlayerIndicator.text = "Paused"
        case .playing:
            trackPlayerIndicator.text = "Playing"
        case .buffering:
            trackPlayerIndicator.text = "Buffering"
        }
    }
}
