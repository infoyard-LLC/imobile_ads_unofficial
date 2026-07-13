# Copy this file to <your Flutter app>/ios/ImobileSdkAds.podspec.
# Place the official framework at:
#   <your Flutter app>/ios/Frameworks/ImobileSdkAds.xcframework
#
# Update s.version when you install a different i-mobile SDK release.

Pod::Spec.new do |s|
  s.name = 'ImobileSdkAds'
  s.version = '2.3.4'
  s.summary = 'Local wrapper for the official i-mobile iOS SDK.'
  s.description = 'References an i-mobile SDK obtained directly by the app developer. The binary is not redistributed by imobile_ads_unofficial.'
  s.homepage = 'https://sppartner.i-mobile.co.jp/sdk_download.aspx'
  s.license = { :type => 'Proprietary', :text => 'Use is governed by the terms supplied with the official i-mobile SDK.' }
  s.author = { 'i-mobile Co., Ltd.' => 'https://www.i-mobile.co.jp/' }
  s.source = { :path => '.' }
  s.platform = :ios, '15.0'
  s.static_framework = true
  s.vendored_frameworks = 'Frameworks/ImobileSdkAds.xcframework'
  s.frameworks = 'AdSupport', 'SystemConfiguration', 'CoreLocation', 'WebKit', 'StoreKit'
  s.weak_frameworks = 'UIKit', 'Foundation'
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  s.user_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
end
