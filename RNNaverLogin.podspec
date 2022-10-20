require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNNaverLogin"
  s.version      = package['version']
  s.summary      = "Naver Login Module for React Native (iOS and Android)"
  s.description  = <<-DESC
                  RNNaverLogin
                   DESC
  s.homepage     = "https://github.com/react-native-seoul/react-native-naver-login.git"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "dooboolab@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/react-native-seoul/react-native-naver-login.git", :tag => "main" }
  s.source_files  = "ios/**/*.{h,m,swift}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency 'naveridlogin-sdk-ios', '~> 4.1.5'

end

