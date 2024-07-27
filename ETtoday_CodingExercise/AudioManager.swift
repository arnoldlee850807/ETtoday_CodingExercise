//
//  AudioManager.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/26/24.
//

import Combine
import AVFoundation

enum PlayerStatus {
    case finished
    case paused
    case playing
    case buffering
}

class AudioManager {
    static let shared = AudioManager()
    var player = AVPlayer()
    private var session = AVAudioSession.sharedInstance()

    private var playToEndCancellable: AnyCancellable?
    private var bufferingCancellable: AnyCancellable?
    
    
    private var isPlaybackBufferEmptyObserver: NSKeyValueObservation?
    private var isPlaybackBufferFullObserver: NSKeyValueObservation?
    private var isPlaybackLikelyToKeepUpObserver: NSKeyValueObservation?
    
    
    private var audioURL: URL?
    var playerStatus = ObservableObject(PlayerStatus.paused)
    
    public func playAndPauseAudio(with url: URL) {
        activateSession()
        
        let playerItem = AVPlayerItem(url: url)
        
        if audioURL == url {
            switch playerStatus.value {
            case .paused:
                player.play()
                playerStatus.value = .playing
            case .playing:
                player.pause()
                playerStatus.value = .paused
            case .finished:
                player.seek(to: .zero)
                player.play()
                playerStatus.value = .playing
            case .buffering:
                return
            }
            return
        } else {
            player.replaceCurrentItem(with: playerItem)
        }
        
        audioURL = url
        
        // Track ended notification
        playToEndCancellable = NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification).sink { _ in
            self.playerStatus.value = .finished
            self.deactivateSession()
        }
        
        // Track stopped playing need more buffering notification
        bufferingCancellable = NotificationCenter.default.publisher(for: AVPlayerItem.playbackStalledNotification).sink { _ in
            self.playerStatus.value = .buffering
        }
        
        // Start buffering observer
        isPlaybackBufferEmptyObserver = playerItem.observe(\.isPlaybackBufferEmpty, changeHandler: onIsPlaybackBufferEmptyObserverChanged)
        // Finshed buffering observer
        isPlaybackBufferFullObserver = playerItem.observe(\.isPlaybackBufferFull, changeHandler: onIsPlaybackBufferFullObserverChanged)
        // Track ready to play observer
        isPlaybackLikelyToKeepUpObserver = playerItem.observe(\.isPlaybackLikelyToKeepUp, changeHandler: onIsPlaybackLikelyToKeepUpObserverChanged)
        
        playerStatus.value = .buffering
        player.play()
    }
    
    private func onIsPlaybackBufferEmptyObserverChanged(playerItem: AVPlayerItem, change: NSKeyValueObservedChange<Bool>) {
        if playerItem.isPlaybackBufferEmpty {
            playerStatus.value = .buffering
        }
    }

    private func onIsPlaybackBufferFullObserverChanged(playerItem: AVPlayerItem, change: NSKeyValueObservedChange<Bool>) {
        if playerItem.isPlaybackBufferFull {
            playerStatus.value = .playing
        }
    }

    private func onIsPlaybackLikelyToKeepUpObserverChanged(playerItem: AVPlayerItem, change: NSKeyValueObservedChange<Bool>) {
        if playerItem.isPlaybackLikelyToKeepUp {
            playerStatus.value = .playing
        }
    }
    
    // Not using
    private func getPlayerStatus() -> PlayerStatus {
        if player.timeControlStatus == .playing {
            return .playing
        } else if player.timeControlStatus == .paused {
            return player.currentTime() == player.currentItem?.duration ? .finished:.paused
        } else {
            return .finished
        }
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
