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
  @IBOutlet weak var labelRemainingTime: UILabel!
  @IBOutlet weak var labelEllapsedTime: UILabel!
  @IBOutlet weak var sliderDuration: Slider!
  
  let player = IPlayer.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    player.viewDelegate = self
    
  }
  
  override func prefersHomeIndicatorAutoHidden() -> Bool {
    return true
  }
  
  @IBAction func sliderValueChanged(_ sender: UISlider) {
    
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
  
  func player(updatedTo watchTime: String, and remainingTime: String, with completedPercent: Float) {
    labelEllapsedTime.text = watchTime
    labelRemainingTime.text = remainingTime
    
    sliderDuration.value = completedPercent
  }
  
  
  func playerDidFinishPlaying() {
    
  }
  
  func player(failedWith error: String?) {
    if let error = error {
      print(error)
    }
  }
}
