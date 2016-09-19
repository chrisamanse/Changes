Pod::Spec.new do |s|
  s.name         = "Changes"
  s.version      = "2.0.0"
  s.summary      = "A Swift framework that computes changes occurred in a `Collection`"
  s.description  = "A Swift framework that computes changes occurred in a `Collection`. Elements of the collection should conform to `Equatable`."

  s.homepage     = "https://github.com/chrisamanse/Changes"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Chris Amanse" => "chris@chrisamanse.xyz" }
  s.social_media_url   = "http://twitter.com/ChrisAmanse"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "10"

  s.source        = { :git => "https://github.com/chrisamanse/Changes.git", :tag => "#{s.version}" }
  s.source_files  = "Source", "Source/**/*.{h,swift}"
  s.requires_arc  = true
end
