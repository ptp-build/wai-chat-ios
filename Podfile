platform :ios, '9.0'

target 'U17' do
    use_frameworks!
  inhibit_all_warnings!

pod 'SnapKitExtend'
pod 'Then'
pod 'Moya'
pod 'HandyJSON'
pod 'Kingfisher'
pod 'Reusable'
pod 'MJRefresh'
pod 'MBProgressHUD'
pod 'HMSegmentedControl'
pod 'IQKeyboardManagerSwift'
pod 'EmptyDataSet-Swift'
pod 'UINavigation-SXFixSpace'

end


post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
       end
    end
  end
end
