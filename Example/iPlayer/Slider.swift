//
//  Slider.swift
//  iPlayer_Example
//
//  Created by Pushparaj Jayaseelan on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class Slider: UISlider {

  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
    setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .selected)
    setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

}
