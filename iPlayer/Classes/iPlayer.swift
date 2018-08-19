//
//  iPlayer.swift
//  iPlayer
//
//  Created by Pushparaj Jayaseelan on 16/08/18.
//

import UIKit
import AVKit

protocol IPlayerDelegate: class {
  func configure(in view: UIView)
  
  func prepare(with url: String)
  
  func play()
  
  func pause()
  
  func stop()
  
  func seekTo(time: Float)
  
  func reset()
}

protocol IPlayerViewDelegate: class {
  func player(updatedTo state: IPlayerState)
  
  func player(updatedTo watchTime: TimeInterval,
              and remainingTime: TimeInterval)
  
  func playerDidFinishPlaying()
  
  func player(failedWith error: IPlayerError)
}

enum IPlayerState {
  case preparing
  
  case buffering
  
  case playing
  
  case paused
  
  case stopped
  
  case unknown
}

enum IPlayerError {
  case unknown
  
  case invalidVideoURL
}

class IPlayer: NSObject {
  
  static let instance = IPlayer()
  
  private var player: AVQueuePlayer?
  
  private var playerLayer: AVPlayerLayer?
  
  private var playbackLikelyToKeepUpContext = 0
  
  private var playbackBufferEmpty = 0
  
  private var state: IPlayerState = .unknown {
    didSet {
      view?.player(updatedTo: state)
    }
  }
  
  weak var view: IPlayerViewDelegate?
  
  private override init() {
    
  }
  
  private func registerAVPlayerEventHandlers() {
    player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp), options: .new, context: &playbackLikelyToKeepUpContext)
    player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty), options: .new, context: &playbackBufferEmpty)
  }
}

extension IPlayer: IPlayerDelegate {
  
  func configure(in view: UIView) {
    playerLayer = AVPlayerLayer(layer: view.layer)
  }
  
  func prepare(with url: String) {
    guard playerLayer != nil else {
      #if DEBUG
      print("No valid player layer found. Stop preparing...")
      #endif
      return
    }
    
    guard let assetPath = URL(string: url) else {
      view?.player(failedWith: .invalidVideoURL)
      return
    }
    
    let playerItem = AVPlayerItem(url: assetPath)
    
    if player == nil {
      player = AVQueuePlayer(playerItem: playerItem)
      playerLayer?.player = player
      
      registerAVPlayerEventHandlers()
    } else {
      player?.replaceCurrentItem(with: playerItem)
    }
    
    let notificationName = Notification.Name.AVPlayerItemDidPlayToEndTime
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(notification:)), name: notificationName, object: playerItem)
    
    player?.play()
  }
  
  func play() {
    guard let player = player else { return }
    
    guard state != .playing &&
      (state == .paused || state == .stopped) else { return }
    
    player.play()
    state = .playing
  }
  
  func pause() {
    guard let player = player else { return }
    
    guard state == .playing else { return }
    
    player.pause()
    state = .paused
  }
  
  func seekTo(time: Float) {
    guard let player = player else { return }
    
    let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
    let elapsedTime = videoDuration * Float64(time)
    
    if videoDuration.isFinite {
      view?.player(updatedTo: elapsedTime, and: videoDuration)
      
      player.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed) in
        self.state = .playing
        player.play()
      }
    }
  }
  
  func stop() {
    guard let player = player else { return }
    
    guard state != .unknown || state != .stopped else { return }
    
    player.pause()
    player.seek(to: CMTimeMakeWithSeconds(0, 100))
    state = .stopped
  }
  
  func reset() {
    guard let player = player else { return }
    
    player.pause()
    player.replaceCurrentItem(with: nil)
    self.player = nil
    
    state = .unknown
  }
  
  @objc func playerDidFinishPlaying(notification: Notification) {
    
  }
}

