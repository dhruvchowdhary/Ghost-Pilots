# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'APBOv2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for APBOv2
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Google-Mobile-Ads-SDK'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
