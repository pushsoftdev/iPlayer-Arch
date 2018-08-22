//
//  VideoPlayerVC.swift
//  iPlayer_Example
//
//  Created by Pushparaj Jayaseelan on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import iPlayer

class VideoPlayerVC: UIViewController {
  
  @IBOutlet weak var viewTopNavBar: UIView?
  @IBOutlet weak var labelTitle: UILabel?
  @IBOutlet weak var viewPlayerDisplay: IPlayerView!
  
  @IBOutlet weak var constraintPlayerViewAspectRatio: NSLayoutConstraint!
  @IBOutlet weak var constraintPlayerViewBottomToSuperView: NSLayoutConstraint!

  let videoAsset = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
  
  override func viewDidLoad() {
    super.viewDidLoad()

    constraintPlayerViewAspectRatio.isActive = false
    constraintPlayerViewBottomToSuperView.isActive = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    viewPlayerDisplay.loadVideo(with: videoAsset)
  }
  
  @IBAction func buttonCloseHandler(_ sender: UIButton) {
    
    viewPlayerDisplay.destroy()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func sliderTouchUpInsideHandler(_ sender: UISlider) {
    
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let orientation = UIDevice.current.orientation
//    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
//    if orientation == .landscapeLeft || orientation == .landscapeRight {
//
//    } else if orientation == .portrait {
//      
//    }
    
    viewPlayerDisplay.updateForOrientation(orientation: orientation)
  }
  
  
}
