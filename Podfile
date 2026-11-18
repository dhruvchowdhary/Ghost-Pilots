# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'APBOv2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for APBOv2
  # Firebase 10.x and Google Mobile Ads 11.x are the first releases that ship
  # PrivacyInfo.xcprivacy for all their bundled SDKs (FirebaseCore,
  # GoogleUtilities, GoogleDataTransport, nanopb, FBLPromises, etc.), which is
  # required to pass App Store submission check ITMS-91061.
  #
  # The deployment target is iOS 15 because Xcode 27 builds nothing older (it
  # was 13 until then, the lowest App Store Connect accepted, error 90068).
  # The app project's IPHONEOS_DEPLOYMENT_TARGET has to match.
  pod 'Firebase/Database', '~> 10.29'
  pod 'Firebase/Analytics', '~> 10.29'
  pod 'Google-Mobile-Ads-SDK', '~> 11.13'

  # leveldb ships its manifest as of 1.22.5; Firebase's ~> 1.22 permits this.
  pod 'leveldb-library', '~> 1.22.6'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
