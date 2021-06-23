platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'Sabbath School' do
  pod 'Armchair'
  pod 'Firebase/Crashlytics'
  pod 'FBSDKLoginKit'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'FontBlaster'
  pod 'GoogleSignIn'
  pod 'Hue'
  pod 'MenuItemKit'
  pod 'R.swift'
  pod 'Shimmer'
  pod 'SwiftEntryKit'
  pod 'SwiftMessages'
  pod 'SwiftDate'
  pod 'Texture'
  pod 'Zip'
end

target 'WidgetExtension' do
  pod 'Hue'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end

    if target.name == 'Armchair'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDebug'
        else
          config.build_settings['OTHER_SWIFT_FLAGS'] = ''
        end
      end
    end
  end
end

target 'SnapshotUITests' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end
