# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

use_frameworks! :linkage => :static

def shared_pods
  pod 'Alamofire', '~> 5.2'
end

target 'YourKitchen' do
  # Comment the next line if you don't want to use dynamic frameworks

  shared_pods

  # Pods for YourKitchen
  pod 'ConcentricOnboarding'
  pod 'SwiftUIRefresh'

  # Crash analytics and regular analytics
  pod 'Firebase/Analytics', '~> 7.1.0'
  pod 'Firebase/Crashlytics'

  # Kingfisher
  pod 'Kingfisher/Core'
  pod 'Kingfisher/SwiftUI'

  # Firebase
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift', '~> 7.1.0-beta'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  # pod 'GoogleMLKit/Translate'
  # pod 'GoogleMLKit/LanguageID'
  
  # Authentication
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'

  # Premium
  pod 'SwiftyStoreKit'

  # Advertisement
  pod 'FBAudienceNetwork'
  pod 'GoogleMobileAdsMediationFacebook'
  pod 'Google-Mobile-Ads-SDK'

end

target 'YourKitchenTV' do
  platform :tvos, '13.0'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for YourKitchenTV
  shared_pods

  # Kingfisher
  pod 'Kingfisher/Core'
  pod 'Kingfisher/SwiftUI'

  # Firebase
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift', '~> 7.1.0-beta'
  pod 'Firebase/Storage'

end

target 'WatchOS Extension' do
  platform :watchos, '6.0' 
  use_frameworks!
  shared_pods

  # Kingfisher
  pod 'Kingfisher/Core'
  pod 'Kingfisher/SwiftUI'
end

target 'YourKitchenWidgetExtension' do

  #Pods for YourKitchen Widget
  shared_pods
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
          if config.name == 'Debug'
              config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
              config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
          end
      end
  end
end
