//
//  BasePlayerVC.swift
//  iPlayer_Example
//
//  Created by Pushparaj Jayaseelan on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import iPlayer

class BasePlayerVC: UIViewController {
  
  @IBOutlet weak var viewTopNavBar: UIView?
  @IBOutlet weak var labelTitle: UILabel?
  @IBOutlet weak var loaderPlayer: UIActivityIndicatorView!
  @IBOutlet weak var viewPlayerDisplay: IPlayerView!
  
  let player = IPlayer.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    player.viewDelegate = self
    
  }
  
  override func prefersHomeIndicatorAutoHidden() -> Bool {
    return true
  }
  
  
}

extension BasePlayerVC: IPlayerViewDelegate {
  
  func player(updatedTo state: IPlayerState) {
    switch state {
    case .preparing, .buffering:
      loaderPlayer.startAnimating()
    case .paused, .stopped:
      loaderPlayer.stopAnimating()
    case .playing:
      loaderPlayer.stopAnimating()
    default:
      break
    }
  }
  
  func player(updatedTo watchTime: TimeInterval, and remainingTime: TimeInterval) {
    
  }
  
  func playerDidFinishPlaying() {
    
  }
  
  func player(failedWith error: IPlayerError) {
    
  }
}
