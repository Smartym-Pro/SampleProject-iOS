# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FirebaseSample' do
  use_frameworks!

	pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/Database'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'SDWebImage'
  pod 'PKHUD'
  pod 'SimpleImageViewer'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['SimpleImageViewer'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end

