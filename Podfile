platform :ios, '14'
use_frameworks!
inhibit_all_warnings!

target 'Sabbath School' do
  pod 'Armchair'
  pod 'Shimmer'
  pod 'SwiftAudio'
  pod 'Texture', :git => 'https://github.com/TextureGroup/Texture.git', :branch => 'master'
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
    if target.name == 'PSPDFKit'
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
  end
end

target 'SnapshotUITests' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end
