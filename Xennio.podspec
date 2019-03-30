#
# Be sure to run `pod lib lint Xennio.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Xennio'
  s.version          = '0.1.0'
  s.swift_version    = '3.2'
  s.summary          = 'Xennio SDK'
  s.description      = 'Xennio iOS SDK'
  s.platform         = :ios, '8.0'
  s.homepage         = 'https://github.com/xennio/harray-ios-client'
  s.license          = 'MIT'
  s.author           = { 'Ozan Uysal' => 'ozan.uysal@appcent.mobi' }
  s.source           = { :git => 'https://github.com/xennio/harray-ios-client'}
  s.source_files = 'Pod/Classes/**/*'

end
