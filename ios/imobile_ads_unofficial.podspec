#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint imobile_ads_unofficial.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'imobile_ads_unofficial'
  s.version          = '0.0.1'
  s.summary          = 'Unofficial Flutter plugin for i-mobile ads (interstitial and banner).'
  s.description      = <<-DESC
Unofficial Flutter plugin for displaying i-mobile interstitial and banner ads on iOS. Not affiliated with i-mobile Co., Ltd.
                       DESC
  s.homepage         = 'https://github.com/infoyard-LLC/imobile_ads_unofficial'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Full of clouds, infoyard LLC.' => 'info@infoyard.jp' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  # https://sppartner.i-mobile.co.jp/sdk_download.aspx でDL
  s.vendored_frameworks = 'Frameworks/*.xcframework'
  s.frameworks = 'AdSupport', 'SystemConfiguration', 'CoreLocation', 'WebKit', 'StoreKit'
  s.weak_frameworks = 'UIKit', 'Foundation'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # 追加
    'SWIFT_INCLUDE_PATHS' => '"$(PODS_TARGET_SRCROOT)/Frameworks"',
    'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_TARGET_SRCROOT)/Frameworks/**/Headers"',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  s.user_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }

  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'imobile_ads_unofficial_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
