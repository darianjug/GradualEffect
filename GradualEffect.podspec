#
# Be sure to run `pod lib lint GradualEffect.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GradualEffect'
  s.version          = '0.1.0'
  s.summary          = 'Gradually blur the background as the user scrolles. Blazing fast.'

# Gradually blur the background as the user scrolles. It's blazing fast and it uses the GPU instead of the CPU.

  s.description      = <<-DESC
Gradually blur the background as the user scrolles. It's blazing fast and it uses the GPU instead of the CPU.
                       DESC

  s.homepage         = 'https://github.com/darianjug/GradualEffect'
                                                s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Darian Jug' => 'darian.jug@me.com' }
  s.source           = { :git => 'https://github.com/darianjug/GradualEffect.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Darian_Jug'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GradualEffect/Classes/**/*.swift'
  
  # s.resource_bundles = {
  #   'GradualEffect' => ['GradualEffect/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'GPUImage', '~> 0.1.7'
end
