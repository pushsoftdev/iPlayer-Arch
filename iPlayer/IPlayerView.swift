//
//  IPlayerView.swift
//  iPlayer
//
//  Created by Pushparaj Jayaseelan on 20/08/18.
//

import UIKit
import AVKit

public protocol IPlayerViewDelegate: class {
  func playerViewDidFinishPlaying()
  func playerView(playerView: IPlayerView, failedWith error: IPlayerError)
}

public class IPlayerView: UIView {
  
  open var bottomView: UIView!
  
  open var labelElapsedTime: UILabel!
  
  open var labelRemainingTime: UILabel!
  
  open var loader: UIActivityIndicatorView!
  
  open var sliderDuration: UISlider!
  
  open var buttonPlayPause: UIButton!
  
  open var player = IPlayer.shared
  
  public weak var delegage: IPlayerViewDelegate?
  
  override public static var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
  
  public var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
  
  private var tapRecognizer: UITapGestureRecognizer!
  
  private var isControlsShowing = true {
    willSet {
      updateControlsVisibility(shouldShow: !isControlsShowing)
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureUI()
  }
  
  private func configureUI() {
    bottomView = UIView()
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    bottomView.backgroundColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.7)
    addSubview(bottomView)
    
    labelElapsedTime = UILabel()
    configureDurationLabel(label: labelElapsedTime)
    labelElapsedTime.translatesAutoresizingMaskIntoConstraints = false
    bottomView.addSubview(labelElapsedTime)
    
    labelRemainingTime = UILabel()
    configureDurationLabel(label: labelRemainingTime)
    labelRemainingTime.translatesAutoresizingMaskIntoConstraints = false
    bottomView.addSubview(labelRemainingTime)
    
    loader = UIActivityIndicatorView()
    loader.hidesWhenStopped = true
    loader.startAnimating()
    loader.translatesAutoresizingMaskIntoConstraints = false
    addSubview(loader)
    
    sliderDuration = UISlider()
    sliderDuration.translatesAutoresizingMaskIntoConstraints = false
    configureSlider()
    bottomView.addSubview(sliderDuration)
    
    buttonPlayPause = UIButton()
    buttonPlayPause.translatesAutoresizingMaskIntoConstraints = false
    buttonPlayPause.addTarget(self, action: #selector(buttonPlayPauseHandler), for: .touchUpInside)
    addSubview(buttonPlayPause)
    
    configureAutoLayout()
    
    player.delegate = self
    player.configure(in: self)
    
    configureTapRecognizer()
  }
  
  private func configureTapRecognizer() {
    tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    isUserInteractionEnabled = true
    addGestureRecognizer(tapRecognizer)
  }
  
  @objc func tapHandler() {
    isControlsShowing = !isControlsShowing
  }
  
  private func updateControlsVisibility(shouldShow: Bool) {
    var toAlpha: CGFloat!
    
    if !shouldShow {
      toAlpha = 0.0
    } else {
      toAlpha = 1.0
    }
    
    UIView.animate(withDuration: 0.3) {
      self.bottomView.alpha = toAlpha
      self.buttonPlayPause.alpha = toAlpha
    }
    
    buttonPlayPause.isHidden = !shouldShow
  }
  
  public func loadVideo(with url: String) {
    player.prepare(with: url)
  }
  
  public func updateForOrientation(orientation: UIDeviceOrientation) {
    if orientation.isLandscape {
      bottomView.layer.cornerRadius = 5
    } else {
      bottomView.layer.cornerRadius = 0
    }
  }
  
  public func destroy() {
    player.reset()
  }
  
  private func configureSlider() {
    sliderDuration.maximumTrackTintColor =
      UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5)
    sliderDuration.minimumTrackTintColor =
      UIColor(red: 204.0 / 255.0, green: 8.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    sliderDuration.thumbTintColor = .clear
  }
  
  private func configureDurationLabel(label: UILabel) {
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 13)
    label.text = "00:00:00"
  }
  
  private func configureAutoLayout() {
    layoutElapsedTime()
    
    layoutRemainingTime()
    
    layoutSlider()
    
    layoutLoader()
    
    layoutPlayPauseButton()
    
    layoutBottomView()
  }
  
  private func layoutLoader() {
    let constraintLoaderCenterYInSuperView = NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    
    let constraintLoaderCenterXInSuperView = NSLayoutConstraint(item: loader, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
    
    addConstraints([constraintLoaderCenterXInSuperView, constraintLoaderCenterYInSuperView])
  }
  
  private func layoutBottomView() {
    let constraintBottomViewBottomToSuperView = NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
    
    let constraintBottomViewLeadingToSuperView = NSLayoutConstraint(item: bottomView, attribute: .leadingMargin, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0)
    
    let constraintBottomViewTrailingToSuperView = NSLayoutConstraint(item: bottomView, attribute: .trailingMargin, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: 0)
    
    addConstraints([constraintBottomViewBottomToSuperView, constraintBottomViewLeadingToSuperView, constraintBottomViewTrailingToSuperView])
  }
  
  private func layoutElapsedTime() {
    let constraintElapsedTimeLeadingToSuperView = NSLayoutConstraint(item: labelElapsedTime, attribute: .leadingMargin, relatedBy: .equal, toItem: bottomView, attribute: .leadingMargin, multiplier: 1, constant: 7)
    
    let constraintElapsedTimeCenterYInSuperView = NSLayoutConstraint(item: labelElapsedTime, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0)
    
    let constraintElapsedTimeWidth = NSLayoutConstraint(item: labelElapsedTime, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
    labelElapsedTime.addConstraint(constraintElapsedTimeWidth)
    
    bottomView.addConstraints([constraintElapsedTimeLeadingToSuperView, constraintElapsedTimeCenterYInSuperView])
  }
  
  private func layoutRemainingTime() {
    let constraintRemainingTimeTrailingToSuperView = NSLayoutConstraint(item: labelRemainingTime, attribute: .trailingMargin, relatedBy: .equal, toItem: bottomView, attribute: .trailingMargin, multiplier: 1, constant: -5)
    
    let constriantRemainingTimeCenterYToElapsedTime = NSLayoutConstraint(item: labelRemainingTime, attribute: .centerY, relatedBy: .equal, toItem: labelElapsedTime, attribute: .centerY, multiplier: 1, constant: 0)
    
    let constraintRemainingTimeEqualWidthToElapsedTime = NSLayoutConstraint(item: labelElapsedTime, attribute: .width, relatedBy: .equal, toItem: labelRemainingTime, attribute: .width, multiplier: 1, constant: 0)
    
    bottomView.addConstraint(constraintRemainingTimeEqualWidthToElapsedTime)
    bottomView.addConstraints([constraintRemainingTimeTrailingToSuperView, constriantRemainingTimeCenterYToElapsedTime])
  }
  
  private func layoutSlider() {
    let constraintSliderTopToSuperView = NSLayoutConstraint(item: sliderDuration, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 5)
    
    let constraintSliderBottomToSuperView = NSLayoutConstraint(item: sliderDuration, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: -5)
    
    let constraintSliderLeadingToElapsedTime = NSLayoutConstraint(item: sliderDuration, attribute: .leading, relatedBy: .equal, toItem: labelElapsedTime, attribute: .trailing, multiplier: 1, constant: 7)
    
    let constraintSliderTrailingToRemainingTime = NSLayoutConstraint(item: sliderDuration, attribute: .trailing, relatedBy: .equal, toItem: labelRemainingTime, attribute: .leading, multiplier: 1, constant: -9)
    
    bottomView.addConstraints([constraintSliderTopToSuperView, constraintSliderBottomToSuperView, constraintSliderLeadingToElapsedTime, constraintSliderTrailingToRemainingTime])
  }
  
  private func layoutPlayPauseButton() {
    let constraintPlayPauseCenterYInSuperView = NSLayoutConstraint(item: buttonPlayPause, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    
    let constraintPlayPauseCenterXInSuperView = NSLayoutConstraint(item: buttonPlayPause, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
    
    addConstraints([constraintPlayPauseCenterXInSuperView, constraintPlayPauseCenterYInSuperView])
  }
  
  @objc func buttonPlayPauseHandler() {
    let state = player.playerState()
    switch state {
    case .playing:
      player.pause()
    case .paused, .stopped, .end:
      player.play()
    default:
      break
    }
  }
}

extension IPlayerView: IPlayerDelegate {
  
  public func player(updatedTo state: IPlayerState) {
    handlePlayer(state: state)
  }
  
  public func player(updatedTo watchTime: String, and remainingTime: String, with completedPercent: Float) {
    labelElapsedTime.text = watchTime
    labelRemainingTime.text = remainingTime
    
    sliderDuration.value = completedPercent
  }
  
  public func playerDidFinishPlaying() {
    delegage?.playerViewDidFinishPlaying()
  }
  
  public func player(failedWith error: IPlayerError) {
    delegage?.playerView(playerView: self, failedWith: error)
  }
  
  private func handlePlayer(state: IPlayerState) {
    switch state {
    case .preparing, .buffering:
      loader.startAnimating()
      buttonPlayPause.isHidden = true
    case .paused, .stopped:
      loader.stopAnimating()
      buttonPlayPause.setTitle("Play", for: .normal)
      updateControlsVisibility(shouldShow: true)
    case .playing:
      buttonPlayPause.isHidden = false
      buttonPlayPause.setTitle("Pause", for: .normal)
      loader.stopAnimating()
    case .end:
      buttonPlayPause.setTitle("Play", for: .normal)
      updateControlsVisibility(shouldShow: true)
    default:
      break
    }
  }
}
