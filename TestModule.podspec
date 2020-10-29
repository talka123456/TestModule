
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "TestModule"
  s.version      = "1.0.4"
  s.summary      = "the description of TestModule."
  s.homepage     = "https://github.com/talka123456/TestModule.git"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "ClownFish" => "15800960640@163.com" }
  s.source       = { :git => "https://github.com/talka123456/TestModule.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.source_files  = "TestModule/TestModule/Classes/**/*"
end
