//
//  IPlayerView.swift
//  iPlayer
//
//  Created by Pushparaj Jayaseelan on 20/08/18.
//

import UIKit
import AVKit

public class IPlayerView: UIView {

  override public static var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
  
  public var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
}
