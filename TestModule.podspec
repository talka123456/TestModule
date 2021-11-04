
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "TestModule"
  s.version      = "1.0.5"
  s.summary      = "the description of TestModule."
  s.homepage     = "https://github.com/talka123456/TestModule.git"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "ClownFish" => "15800960640@163.com" }
  s.source       = { :git => "https://github.com/talka123456/TestModule.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '9.0'
  s.source_files  = "TestModule/TestModule/Classes/**/*"
  # s.dependency "RxSwift"
  # s.dependency "Moya"
  s.vendored_framework = "Frameworks/DynamicFrameworkB.framework"
  s.vendored_library = "libraries/libStaticLibraryA.a"
  
  # s.subspec 'Module_1' do |ss|
  #   ss.dependency "RxCocoa"
  # end

  # s.subspec 'Module_2' do |ss|
  #   ss.dependency "YYText"

  #   ss.subspec 'Module_2_2' do |sss|
  #     sss.dependency 'YYImage'
  #   end
  # end
end
