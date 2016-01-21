Pod::Spec.new do |s|

  s.name         = "Changes"
  s.version      = "1.1.0"
  s.summary      = "A Swift framework that computes changes occurred in a `CollectionType`"
  s.description  = "A Swift framework that computes changes occurred in a `CollectionType`. Elements of the collection should also conform to `Equatable`."

  s.homepage     = "https://github.com/chrisamanse/Changes"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Chris Amanse" => "christopheramanse@gmail.com" }
  s.social_media_url   = "http://twitter.com/ChrisAmanse"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/chrisamanse/Changes.git", :tag => "v1.1.0" }
  s.source_files  = "Source", "Source/**/*.{h,swift}"
  s.requires_arc = true
end
