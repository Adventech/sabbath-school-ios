platform :ios, '12.1'
use_frameworks!
inhibit_all_warnings!

target 'Sabbath School' do
  pod 'PSPDFKit', podspec: 'https://customers.pspdfkit.com/pspdfkit-ios/10.4.2.podspec'
  pod 'Armchair'
  pod 'Down'
  pod 'FontBlaster'
  pod 'GoogleSignIn'
  pod 'Hue'
  pod 'MenuItemKit'
  pod 'R.swift'
  pod 'Shimmer'
  pod 'SwiftAudio'
  pod 'SwiftEntryKit'
  pod 'SwiftMessages'
  pod 'SwiftDate'
  pod 'Texture'
  pod 'Zip'
  pod 'Wormholy', :configurations => ['Debug']
end

target 'WidgetExtension' do
  pod 'Hue'
end

def fix_config(config)
   # https://github.com/CocoaPods/CocoaPods/issues/8891
   if config.build_settings['DEVELOPMENT_TEAM'].nil?
     config.build_settings['DEVELOPMENT_TEAM'] = 'XVGX5G4YQ9'
   end
 end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      fix_config(config)
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.1'
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
