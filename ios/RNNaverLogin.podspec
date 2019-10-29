
Pod::Spec.new do |s|
  s.name         = "naver-login"
  s.version      = package['version']
  s.summary      = "Naver Login Module for React Native (iOS and Android)"
  s.description  = <<-DESC
                  RNNaverLogin
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "dooboolab@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/react-native-seoul/naver-login.git", :tag => "master" }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
