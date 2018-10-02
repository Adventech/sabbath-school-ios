platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'Sabbath School' do
  pod 'Armchair', '>= 0.3'
  pod 'Crashlytics'
  pod 'Fabric'
  pod 'FacebookLogin'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'FontBlaster'
  pod 'GoogleSignIn'
  pod 'Hue'
  pod 'JSQWebViewController', '~> 5.0.0'
  pod 'MenuItemKit'
  pod 'pop'
  pod 'R.swift', '~> 3.1'
  pod 'Shimmer'
  pod 'SwiftMessages', '~> 5.0'
  pod 'SwiftDate', '~> 4.0.13'
  pod 'Texture'
  pod 'Unbox'
  pod 'Wrap'
  pod 'Zip', '~> 0.7'
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
