# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CalendarApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CalendarApp
pod 'CalculateCalendarLogic'
pod 'FSCalendar'
pod 'GTMAppAuth'
pod 'AppAuth'
pod 'GoogleAPIClientForREST/Calendar'
pod 'Google-Mobile-Ads-SDK'
pod 'LicensePlist'

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

  target 'CalendarAppTests' do
    inherit! :search_paths
    # Pods for testing
pod 'CalculateCalendarLogic'
pod 'FSCalendar'
pod 'GTMAppAuth'
pod 'AppAuth'
pod 'GoogleAPIClientForREST/Calendar'

  end

  target 'CalendarAppUITests' do
    # Pods for testing
pod 'CalculateCalendarLogic'
pod 'FSCalendar'
pod 'GTMAppAuth'
pod 'AppAuth'
pod 'GoogleAPIClientForREST/Calendar'

  end

end
