//
//  iPlayer.swift
//  iPlayer
//
//  Created by Pushparaj Jayaseelan on 16/08/18.
//

import UIKit
import AVKit

public protocol IPlayerDelegate: class {
  func configure(in view: IPlayerView)
  
  func prepare(with url: String)
  
  func play()
  
  func pause()
  
  func stop()
  
  func seekTo(time: Float)
  
  func setVideoGravity(mode: AVLayerVideoGravity)
  
  func reset()
}

public protocol IPlayerViewDelegate: class {
  func player(updatedTo state: IPlayerState)
  
  func player(updatedTo watchTime: TimeInterval,
              and remainingTime: TimeInterval)
  
  func playerDidFinishPlaying()
  
  func player(failedWith error: IPlayerError)
}

public enum IPlayerState {
  case preparing
  
  case buffering
  
  case playing
  
  case paused
  
  case stopped
  
  case error
  
  case unknown
}

public enum IPlayerError {
  case unknown
  
  case invalidVideoURL
}

public class IPlayer: NSObject {
  
  open static let shared = IPlayer()
  
  private var playerItem: AVPlayerItem? {
    willSet {
      removePlayerItemEventHandlers()
      removePlayerEventNotificationHandlers()
    }
    
    didSet {
      registerPlayerItemEventHandlers()
      registerPlayerEventNotificationHandlers()
    }
  }
  
  private var player: AVQueuePlayer?
  
  private var playerLayer: AVPlayerLayer?
  
  private var playerItemContext = 0
  
  private var state: IPlayerState = .unknown {
    didSet {
      viewDelegate?.player(updatedTo: state)
    }
  }
  
  public weak var viewDelegate: IPlayerViewDelegate?
  
  private override init() {
    
  }
  
  private func registerPlayerItemEventHandlers() {
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: &playerItemContext)
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: .new, context: &playerItemContext)
  }
  
  private func removePlayerItemEventHandlers() {
    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
  }
  
  private func registerPlayerEventNotificationHandlers() {
    let notificationName = Notification.Name.AVPlayerItemDidPlayToEndTime
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(notification:)), name: notificationName, object: playerItem)
  }
  
  private func removePlayerEventNotificationHandlers() {
    NotificationCenter.default
      .removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
  }
  
  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    if context == &playerItemContext {
      if keyPath == #keyPath(AVPlayerItem.status) {
        let status: AVPlayerItemStatus
        if let statusNumber = change?[.newKey] as? NSNumber {
          status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
        } else {
          status = .unknown
        }
        
        handlePlayerItemStatus(status: status)
        
      } else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
        if let playbackBufferEmpty = change?[.newKey] as? Bool {
          if playbackBufferEmpty {
            handleBufferState()
          }
        }
      }
    }
  }
  
  private func handleBufferState() {
    pause()
    state = .buffering
  }
  
  private func handlePlayerItemStatus(status: AVPlayerItemStatus) {
    switch status {
    case AVPlayerItemStatus.unknown:
      handleBufferState()
    case AVPlayerItemStatus.readyToPlay:
      state = .playing
    case AVPlayerItemStatus.failed:
      state = .error
    }
  }
}

extension IPlayer: IPlayerDelegate {
  
  public func configure(in view: IPlayerView) {
    playerLayer = view.playerLayer
  }
  
  public func prepare(with url: String) {
    guard playerLayer != nil else {
      #if DEBUG
      print("No valid player layer found. Stop preparing...")
      #endif
      return
    }
    
    guard let assetPath = URL(string: url) else {
      viewDelegate?.player(failedWith: .invalidVideoURL)
      return
    }
    
    playerItem = AVPlayerItem(url: assetPath)
    
    if player == nil {
      player = AVQueuePlayer(playerItem: playerItem)
      playerLayer?.player = player
      playerLayer?.videoGravity = .resizeAspect
      
      registerPlayerItemEventHandlers()
    } else {
      player?.replaceCurrentItem(with: playerItem)
    }
    
    state = .preparing
    
    registerPlayerEventNotificationHandlers()
    
    player?.play()
  }
  
  public func play() {
    guard let player = player else { return }
    
    guard state != .playing &&
      (state == .paused || state == .stopped) else { return }
    
    player.play()
    state = .playing
  }
  
  public func pause() {
    guard let player = player else { return }
    
    guard state == .playing else { return }
    
    player.pause()
    state = .paused
  }
  
  public func seekTo(time: Float) {
    guard let player = player else { return }
    
    let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
    let elapsedTime = videoDuration * Float64(time)
    
    if videoDuration.isFinite {
      viewDelegate?.player(updatedTo: elapsedTime, and: videoDuration)
      
      player.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed) in
        self.state = .playing
        player.play()
      }
    }
  }
  
  public func setVideoGravity(mode: AVLayerVideoGravity) {
    playerLayer?.videoGravity = mode
  }
  
  public func stop() {
    guard let player = player else { return }
    
    guard state != .unknown || state != .stopped else { return }
    
    player.pause()
    player.seek(to: CMTimeMakeWithSeconds(0, 100))
    state = .stopped
  }
  
  public func reset() {
    guard let player = player else { return }
    
    player.pause()
    playerItem = nil
    player.replaceCurrentItem(with: nil)
    self.player = nil
    
    state = .unknown
  }
  
  @objc func playerDidFinishPlaying(notification: Notification) {
    
  }
}

