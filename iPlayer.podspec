#
# Be sure to run `pod lib lint iPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iPlayer'
  s.version          = '0.1.0'
  s.summary          = 'A fully customisable AVPlayer library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A fully customisable AV Player library. Just pass on the video URL and you are video is ready to play!'

  s.homepage         = 'https://github.com/pushsoftdev/iPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pushsoftdev@gmail.com' => 'pushparaj.jayaseelan' }
  s.source           = { :git => 'https://github.com/pushsoftdev/iPlayer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/devpushpa91'

  s.ios.deployment_target = '9.3'

  s.source_files = 'iPlayer/**/*'
  
  # s.resource_bundles = {
  #   'iPlayer' => ['iPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
