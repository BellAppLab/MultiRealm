Pod::Spec.new do |s|
  s.name             = "MultiRealm"
  s.version          = "0.3.0"
  s.summary          = "Making it easier to work with Realm on the background."
  s.homepage         = "https://github.com/BellAppLab/MultiRealm"
  s.license          = 'MIT'
  s.author           = { "Bell App Lab" => "apps@bellapplab.com" }
  s.source           = { :git => "https://github.com/BellAppLab/MultiRealm.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/BellAppLab'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'Foundation'
  s.dependency 'RealmSwift'
end
