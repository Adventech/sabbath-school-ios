platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'Sabbath School' do
  pod 'Armchair'
  pod 'Crashlytics'
  pod 'Fabric'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'FontBlaster'
  pod 'GoogleSignIn'
  pod 'Hue'
  pod 'MenuItemKit'
  pod 'pop'
  pod 'R.swift'
  pod 'Shimmer'
  pod 'SwiftMessages'
  pod 'SwiftDate'
  pod 'Texture'
  pod 'Unbox'
  pod 'Wrap'
  pod 'Zip'
  pod 'SwiftLint'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
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
