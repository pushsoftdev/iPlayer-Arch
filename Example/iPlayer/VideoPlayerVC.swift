//
//  VideoPlayerVC.swift
//  iPlayer_Example
//
//  Created by Pushparaj Jayaseelan on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class VideoPlayerVC: BasePlayerVC {
  
  @IBOutlet weak var constraintPlayerViewAspectRatio: NSLayoutConstraint!
  @IBOutlet weak var constraintPlayerViewBottomToSuperView: NSLayoutConstraint!

  let videoAsset = "https://vod-a-802.cdn.nextologies.com/JUNE2018/YouAreMyDestiny_EP48.mp4"
  
  override func viewDidLoad() {
    super.viewDidLoad()

    constraintPlayerViewAspectRatio.isActive = false
    constraintPlayerViewBottomToSuperView.isActive = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    player.configure(in: viewPlayerDisplay)
    player.prepare(with: videoAsset)
  }
  
  @IBAction func buttonCloseHandler(_ sender: UIButton) {
    player.reset()
    
    dismiss(animated: true, completion: nil)
  }
  
}
