
Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "TestModule"
  spec.version      = "0.0.1"
  spec.summary      = "the description of TestModule."
  spec.homepage     = "https://github.com/talka123456/TestModule.git"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "ClownFish" => "15800960640@163.com" }
  spec.source       = { :git => "https://github.com/talka123456/TestModule.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '9.0'
  spec.static_framework = true
  spec.source_files  = "TestModule/TestModule/Classes/**/*.{h,m}"

  # spec.public_header_files = "Classes/**/*.h"s
end
