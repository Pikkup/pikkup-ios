Pod::Spec.new do |s|

  s.name = "PNTActivityIndicatorView"
  s.version = "0.1.1"
  s.summary = "A little class that adds custom view to MBProgressHUD"

  s.homepage = "https://github.com/Planet1107/PNTActivityIndicatorView"

  s.license = "MIT"
  
  s.authors = { "Planet 1107" => "info@planet1107.net" }
  s.social_media_url = "https://twitter.com/Planet1107"

  s.screenshots = [ "https://raw.githubusercontent.com/Planet1107/PNTActivityIndicatorView/master/screen1.png",
                     "https://raw.githubusercontent.com/Planet1107/PNTActivityIndicatorView/master/screen2.png" ]

  s.platform = :ios, "6.0"
  s.ios.deployment_target = "6.0"

  s.source = { :git => "https://github.com/Planet1107/PNTActivityIndicatorView.git", :tag => "0.1.1" }
  s.source_files = "PNTActivityIndicatorView"

  s.resources = "PNTActivityIndicatorView/Resources/*.png"

  s.requires_arc = true

  s.dependency "MBProgressHUD", "~> 0.8"

end
