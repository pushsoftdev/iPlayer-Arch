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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func prefersHomeIndicatorAutoHidden() -> Bool {
    return true
  }
  
  @IBAction func sliderValueChanged(_ sender: UISlider) {
    
  }
}
