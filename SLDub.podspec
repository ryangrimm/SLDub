Pod::Spec.new do |s|
  s.name         =  'SLDub'
  s.version      =  '0.1'
  s.platform     =  :ios
  s.authors  	 =  { 'Ryan Grimm' => 'ryan@swelllines.com' }
  s.license      =  { :type => 'MIT', :file => 'LICENSE' }
  s.requires_arc =  true
  s.summary      =  'A dynamic way of annotating UIViews. Can be used to make fairly magical help overlays, show annotations on photos and maybe some other stuff too.'
  s.source_files =  'SLDub/SLDub.h'
  s.homepage     =  'https://github.com/ryangrimm/SLDub'
  s.source       =  { :git => 'https://github.com/ryangrimm/SLDub.git', :tag => '0.1' }
  s.ios.deployment_target = '7.0'
end
