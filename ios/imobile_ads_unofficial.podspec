Pod::Spec.new do |s|
  s.name = 'imobile_ads_unofficial'
  s.version = '0.0.2'
  s.summary = 'Unofficial Flutter plugin for i-mobile ads (interstitial and banner).'
  s.description = <<-DESC
Unofficial Flutter plugin for displaying i-mobile interstitial and banner ads on iOS. Not affiliated with i-mobile Co., Ltd.
  DESC
  s.homepage = 'https://github.com/infoyard-LLC/imobile_ads_unofficial'
  s.license = { :file => '../LICENSE' }
  s.author = { 'Full of clouds, infoyard LLC.' => 'info@infoyard.jp' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'

  s.dependency 'Flutter'

  # The proprietary i-mobile SDK is not bundled with this plugin.
  # The consuming app must provide a local CocoaPod named "ImobileSdkAds".
  # See README.md / README_ja.md and tool/ImobileSdkAds.podspec.
  s.dependency 'ImobileSdkAds'

  s.frameworks = 'AdSupport', 'SystemConfiguration', 'CoreLocation', 'WebKit', 'StoreKit'
  s.weak_frameworks = 'UIKit', 'Foundation'
  s.platform = :ios, '15.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }

  s.user_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }

  s.swift_version = '5.0'
end
