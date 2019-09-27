
Pod::Spec.new do |s|
  s.name         = "RNNaverLogin"
  s.version      = "1.0.0"
  s.summary      = "RNNaverLogin"
  s.description  = <<-DESC
                  RNNaverLogin
                   DESC
  s.homepage     = "https://github.com/react-native-seoul/react-native-naver-login.git"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNNaverLogin.git", :tag => "master" }
  s.source_files  = "RNNaverLogin/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
