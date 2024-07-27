//
//  AudioManager.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/26/24.
//

import Combine
import AVKit
import AVFoundation

enum PlayerStatus {
    case finished
    case paused
    case playing
    case buffering
    case initial
}

class AudioManager {
    static let shared = AudioManager()
    private let player = AVPlayer()
    private var session = AVAudioSession.sharedInstance()

    // Observers
    private var playToEndCancellable: AnyCancellable?
    private var bufferingCancellable: AnyCancellable?
    private var onIsPlaybackLikelyToKeepUpObserver: NSKeyValueObservation?
    private var onRateObserver: NSKeyValueObservation?
    
    private var audioURL: URL?
    var playerStatus = ObservableObject(PlayerStatus.initial)
    var videoControllerPresented = ObservableObject(false)
    private var videoController = AVPlayerViewController()
    
    public func playAndPauseAudio(with url: URL) {
        activateSession()
        
        let playerItem = AVPlayerItem(url: url)
        videoController.player = player
        
        if audioURL == url {
            switch playerStatus.value {
            case .paused, .initial:
                player.play()
            case .playing:
                player.pause()
            case .finished:
                player.seek(to: .zero)
                player.play()
            case .buffering:
                return
            }
            return
        } else {
            player.replaceCurrentItem(with: playerItem)
            playerStatus.value = .initial
        }
        
        audioURL = url
        
        // Track ended notification
        playToEndCancellable = NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification).sink { _ in
            self.playerStatus.value = .finished
            self.videoControllerPresented.value = false
            self.deactivateSession()
        }
        // Track stopped playing need more buffering notification
        bufferingCancellable = NotificationCenter.default.publisher(for: AVPlayerItem.playbackStalledNotification).sink { _ in
            self.playerStatus.value = .buffering
        }
        onIsPlaybackLikelyToKeepUpObserver = playerItem.observe(\.isPlaybackLikelyToKeepUp, changeHandler: onIsPlaybackLikelyToKeepUpObserverChanged)
        // Track playing rate observer
        onRateObserver = player.observe(\.rate, changeHandler: onRateObserverChanged)
        
        playerStatus.value = .buffering
    }
    
    // Determine when buffering ends and ready to play
    private func onIsPlaybackLikelyToKeepUpObserverChanged(playerItem: AVPlayerItem, change: NSKeyValueObservedChange<Bool>) {
        if playerItem.isPlaybackLikelyToKeepUp && playerStatus.value != .finished {
            player.play()
        }
    }
    
    // Determine states using rate change
    private func onRateObserverChanged(player: AVPlayer, change: NSKeyValueObservedChange<Float>) {
        if player.rate == 1.0 {
            player.currentItem?.asset.loadTracks(withMediaType: .video, completionHandler: { tracks, error in
                if tracks?.isEmpty == false {
                    self.videoControllerPresented.value = true
                }
            })
            playerStatus.value = .playing
        } else {
            if player.currentItem?.currentTime() == player.currentItem?.duration {
                playerStatus.value = .finished
            } else {
                playerStatus.value = .paused
            }
        }
    }
    
    public func getVideoController() -> AVPlayerViewController {
        return videoController
    }
    
    private func activateSession() {
        do {
            try session.setMode(.default)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            try session.overrideOutputAudioPort(.speaker)
        } catch {
            print("AVAudioSession activate failed")
        }
    }
    
    private func deactivateSession() {
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            print("Deactivate audio session failed: \(error.localizedDescription)")
        }
    }
}
