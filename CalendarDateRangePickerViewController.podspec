Pod::Spec.new do |s|
  s.name             = 'CalendarDateRangePickerViewController'
  s.version          = '0.2.0'
  s.summary          = 'A calendar date range picker view controller in Swift for iOS.'
  s.description      = <<-DESC
    This is a calendar date range picker view controller written in Swift for iOS.
    The typical use case is where you want the user to input a date range, i.e. a start date and an end date.
    This view controller allows this in an intuitive way, and is easy to use by implementing the delegate methods.
    See the example project for a taste.
  DESC

  s.homepage         = 'https://github.com/miraan/CalendarDateRangePickerViewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'miraan' => 'miraan@triprapp.com' }
  s.source           = { :git => 'https://github.com/miraan/CalendarDateRangePickerViewController.git', :tag => s.version.to_s }
  s.source_files = 'CalendarDateRangePickerViewController/Classes/**/*'

  s.ios.deployment_target = '8.0'

  s.swift_version = '5.0'
end
