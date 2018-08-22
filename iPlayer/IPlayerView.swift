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
  
  open var iPlayer = IPlayer.shared
  
  public weak var delegage: IPlayerViewDelegate?
  
  override public static var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
  
  public var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
  
  private var tapRecognizer: UITapGestureRecognizer!
  
  private var doubleTapRecognizer: UITapGestureRecognizer!
  
  private var videoMode: AVLayerVideoGravity = .resizeAspect
  
  private var isControlsShowing = true {
    willSet {
      updateControlsVisibility(shouldShow: !isControlsShowing)
    }
  }
  
  private var sliderThumb: UIImage {
    return imageWithName(name: "slider_thumb")!
  }
  
  // Constraints
  private var constraintBottomViewBottomToSuperView: NSLayoutConstraint!
  private var constraintBottomViewLeadingToSuperView: NSLayoutConstraint!
  private var constraintBottomViewTrailingToSuperView: NSLayoutConstraint!
  
  private var bottomViewXMarginPortrait: CGFloat = 0.0
  private var bottomViewXMarginLandscape: CGFloat = 10.0
  private var bottomViewBottomMarginPortrait: CGFloat = 0.0
  private var bottomViewBottomMarginLandscape: CGFloat = -10.0
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    configureUI()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureUI()
  }
  
  private func imageWithName(name: String) -> UIImage? {
    let frameworkBundle = Bundle(for: IPlayerView.self)
    
    if let bundleURL = frameworkBundle.url(forResource: "iPlayerView", withExtension: "bundle") {
      let bundle = Bundle(url: bundleURL)
      let image = UIImage(named: name, in: bundle, compatibleWith: nil)
      return image
    }
    
    return UIImage()
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
    
    buttonPlayPause = UIButton(type: .system)
    buttonPlayPause.tintColor = .white
    buttonPlayPause.translatesAutoresizingMaskIntoConstraints = false
    buttonPlayPause.addTarget(self, action: #selector(buttonPlayPauseHandler), for: .touchUpInside)
    addSubview(buttonPlayPause)
    
    configureAutoLayout()
    
    iPlayer.delegate = self
    iPlayer.configure(in: self)
    
    isUserInteractionEnabled = true
    
    configureTapRecognizer()
    configureDoubleTapRecognizer()
    
    updateForOrientation(orientation: UIDevice.current.orientation)
  }
  
  private func configureTapRecognizer() {
    tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    addGestureRecognizer(tapRecognizer)
  }
  
  private func configureDoubleTapRecognizer() {
    tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
    tapRecognizer.numberOfTapsRequired = 2
    addGestureRecognizer(tapRecognizer)
  }
  
  @objc func tapHandler() {
    isControlsShowing = !isControlsShowing
  }
  
  @objc func doubleTapHandler() {
    if videoMode == .resizeAspect {
      videoMode = .resizeAspectFill
    } else if videoMode == .resizeAspectFill {
      videoMode = .resizeAspect
    }
    
    iPlayer.setVideoGravity(mode: videoMode)
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
    iPlayer.prepare(with: url)
  }
  
  public func updateForOrientation(orientation: UIDeviceOrientation) {
    if orientation.isLandscape {
      bottomView.layer.cornerRadius = 10
      constraintBottomViewBottomToSuperView.constant = bottomViewBottomMarginLandscape
      constraintBottomViewLeadingToSuperView.constant = bottomViewXMarginLandscape
      constraintBottomViewTrailingToSuperView.constant = -bottomViewXMarginLandscape
    } else {
      bottomView.layer.cornerRadius = 0
      constraintBottomViewBottomToSuperView.constant = bottomViewXMarginPortrait
      constraintBottomViewLeadingToSuperView.constant = bottomViewXMarginPortrait
      constraintBottomViewTrailingToSuperView.constant = bottomViewXMarginPortrait
    }
  }
  
  public func destroy() {
    iPlayer.reset()
  }
  
  private func configureSlider() {
    sliderDuration.minimumValue = 0
    sliderDuration.maximumValue = 1
    
    sliderDuration.maximumTrackTintColor =
      UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.5)
    sliderDuration.minimumTrackTintColor =
      UIColor(red: 204.0 / 255.0, green: 8.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    
    sliderDuration.setThumbImage(UIImage(), for: .normal)
    sliderDuration.setThumbImage(sliderThumb, for: .highlighted)
    sliderDuration.setThumbImage(sliderThumb, for: .selected)
    
    sliderDuration.addTarget(self, action: #selector(sliderValueChangeHandler), for: .valueChanged)
    sliderDuration.addTarget(self, action: #selector(sliderBeginTracking), for: .touchDown)
    sliderDuration.addTarget(self, action: #selector(sliderEndTracking), for: .touchUpInside)
    sliderDuration.addTarget(self, action: #selector(sliderEndTracking), for: .touchUpOutside)
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
     constraintBottomViewBottomToSuperView = NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
    
    constraintBottomViewLeadingToSuperView = NSLayoutConstraint(item: bottomView, attribute: .leadingMargin, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: bottomViewXMarginPortrait)
    
    constraintBottomViewTrailingToSuperView = NSLayoutConstraint(item: bottomView, attribute: .trailingMargin, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: bottomViewXMarginPortrait)
    
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
    let constraintSliderTopToSuperView = NSLayoutConstraint(item: sliderDuration, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 15)
    
    let constraintSliderBottomToSuperView = NSLayoutConstraint(item: sliderDuration, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: -15)
    
    let constraintSliderLeadingToElapsedTime = NSLayoutConstraint(item: sliderDuration, attribute: .leading, relatedBy: .equal, toItem: labelElapsedTime, attribute: .trailing, multiplier: 1, constant: 7)
    
    let constraintSliderTrailingToRemainingTime = NSLayoutConstraint(item: sliderDuration, attribute: .trailing, relatedBy: .equal, toItem: labelRemainingTime, attribute: .leading, multiplier: 1, constant: -9)
    
    let constraintSliderHeight = NSLayoutConstraint(item: sliderDuration, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 11)
    sliderDuration.addConstraint(constraintSliderHeight)
    
    bottomView.addConstraints([constraintSliderTopToSuperView, constraintSliderBottomToSuperView, constraintSliderLeadingToElapsedTime, constraintSliderTrailingToRemainingTime])
  }
  
  private func layoutPlayPauseButton() {
    let constraintPlayPauseCenterYInSuperView = NSLayoutConstraint(item: buttonPlayPause, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    
    let constraintPlayPauseCenterXInSuperView = NSLayoutConstraint(item: buttonPlayPause, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
    
    addConstraints([constraintPlayPauseCenterXInSuperView, constraintPlayPauseCenterYInSuperView])
  }
  
  @objc func buttonPlayPauseHandler() {
    let state = iPlayer.playerState()
    switch state {
    case .playing:
      iPlayer.pause()
    case .paused, .stopped, .end:
      iPlayer.play()
    default:
      break
    }
  }
  
  @objc func sliderValueChangeHandler() {
    guard let duration = iPlayer.currentItemDuration() else { return }
    
    let videoDuration = CMTimeGetSeconds(duration)
    let elapsedTime = videoDuration * Float64(sliderDuration.value)
    
    if videoDuration.isFinite {
        handlePlayerTime(elapsedTime: elapsedTime, videoDuration: videoDuration)
    }
  }
  
  @objc func sliderBeginTracking() {
    sliderDuration.setThumbImage(sliderThumb, for: .normal)
    iPlayer.pause()
  }
  
  @objc func sliderEndTracking() {
    sliderDuration.setThumbImage(UIImage(), for: .normal)
    iPlayer.seekTo(time: sliderDuration.value)
  }
  
  /// Creates the remaining duration of the video.
  ///
  /// - Parameters:
  ///   - elapsedTime: Contains the elapsed time.
  ///   - videoDuration: Contains the video duration.
  func handlePlayerTime(elapsedTime: Float64, videoDuration: Float64) {
    let elapsedTimeFormatted = String(format: "%02d:%02d:%02d", (lround(elapsedTime) / 3600), ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
    
    let timeRemaining: Float64 = videoDuration - elapsedTime
    let timeRemaningFormatted = String(format: "%02d:%02d:%02d", (lround(timeRemaining) / 3600), ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    
    let elapsedPercentage = elapsedTime / videoDuration // 0 to 1
    print("\(elapsedTime) totalDuration: \(videoDuration) Percent: \(elapsedPercentage)")
    
    labelElapsedTime.text = elapsedTimeFormatted
    labelRemainingTime.text = timeRemaningFormatted
    
    sliderDuration.value = Float(elapsedPercentage)
  }
}

extension IPlayerView: IPlayerDelegate {
  
  public func player(updatedTo state: IPlayerState) {
    handlePlayer(state: state)
  }
  
  public func player(updatedTo watchTime: Float64, and remainingTime: Float64) {
    handlePlayerTime(elapsedTime: watchTime, videoDuration: remainingTime)
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
      buttonPlayPause.setImage(imageWithName(name: "media_play"), for: .normal)
      updateControlsVisibility(shouldShow: true)
    case .playing:
      buttonPlayPause.isHidden = false
      buttonPlayPause.setImage(imageWithName(name: "media_pause"), for: .normal)
      loader.stopAnimating()
    case .end:
      buttonPlayPause.setImage(imageWithName(name: "media_play"), for: .normal)
      updateControlsVisibility(shouldShow: true)
      sliderDuration.value = 1.0
      sliderDuration.setThumbImage(sliderThumb, for: .normal)
    default:
      break
    }
  }
}
