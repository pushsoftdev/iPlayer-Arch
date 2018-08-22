//
//  iPlayer.swift
//  iPlayer
//
//  Created by Pushparaj Jayaseelan on 16/08/18.
//

import UIKit
import AVKit

public protocol IPlayerDelegate: class {
  func player(updatedTo state: IPlayerState)
  
  func player(updatedTo watchTime: Float64,
              and remainingTime: Float64)
  
  func playerDidFinishPlaying()
  func player(failedWith error: IPlayerError)
}

public enum IPlayerState {
  case preparing
  case buffering
  case playing
  case paused
  case stopped
  case end
  case error
  case unknown
}

public enum IPlayerErrorType {
  case unknown
  case invalidURL
}

public struct IPlayerError {
  var type: IPlayerErrorType
  var message: String
  
  init(type: IPlayerErrorType, message: String) {
    self.type = type
    self.message = message
  }
}

public class IPlayer: NSObject {
  
  open static let shared = IPlayer()
  
  private var playerItem: AVPlayerItem? {
    willSet {
      removePlayerItemEventHandlers()
      removePlayerEventNotificationHandlers()
    }
    
    didSet {
      guard playerItem != nil else { return }
      
      registerPlayerItemEventHandlers()
      registerPlayerEventNotificationHandlers()
    }
  }
  
  private var player: AVPlayer? {
    willSet {
      removePlayerObservers()
    }
    
    didSet {
      addPlayerObservers()
    }
  }
  
  private var playerLayer: AVPlayerLayer?
  
  private var playerItemContext = 0
  
  private var state: IPlayerState = .unknown {
    didSet {
      delegate?.player(updatedTo: state)
    }
  }
  
  private var timeObserver: Any?
  
  public weak var delegate: IPlayerDelegate?
  
  private override init() {
    
  }
  
  private func addPlayerObservers() {
    timeObserver = player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] elapsedTime in
      guard let strongSelf = self else { return }
      
      guard let currentItem = strongSelf.player?.currentItem else { return }
      
      let currentTime = CMTimeGetSeconds(elapsedTime)
      let totalDuration = CMTimeGetSeconds(currentItem.duration)
      
      if totalDuration.isFinite {
        strongSelf.delegate?.player(updatedTo: currentTime, and: totalDuration)
      }
    })
  }
  
  private func removePlayerObservers() {
    player?.removeTimeObserver(timeObserver!)
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
            state = .buffering
          }
        }
      }
    }
  }
  
  private func handlePlayerItemStatus(status: AVPlayerItemStatus) {
    switch status {
    case AVPlayerItemStatus.unknown:
      state = .buffering
    case AVPlayerItemStatus.readyToPlay:
      state = .playing
    case AVPlayerItemStatus.failed:
      state = .error
      
      if let reason = playerItem?.error?.localizedDescription {
        let error = IPlayerError(type: .unknown, message: reason)
        delegate?.player(failedWith: error)
      }
    }
  }
  
  // MARK: - Configuration Methods
  
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
      //      viewDelegate?.player(failedWith: .invalidVideoURL)
      #if DEBUG
      print("No valid player URL found. Stop preparing...")
      #endif
      return
    }
    
    playerItem = AVPlayerItem(url: assetPath)
    
    if player == nil {
      player = AVPlayer(playerItem: playerItem)
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
      (state == .paused || state == .stopped || state == .end) else { return }
    
    if state == .end || state == .stopped {
      seekTo(time: 0.0)
    }
    
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
      delegate?.player(updatedTo: elapsedTime, and: videoDuration)
      
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
    seekTo(time: 0.0)
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
  
  public func playerState() -> IPlayerState {
    return state
  }
  
  public func currentItemDuration() -> CMTime? {
    return playerItem?.duration
  }
  
  @objc func playerDidFinishPlaying(notification: Notification) {
    state = .end
    delegate?.player(updatedTo: .end)
  }
}
