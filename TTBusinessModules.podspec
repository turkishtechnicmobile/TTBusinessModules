Pod::Spec.new do |spec|
  spec.name         = 'TTBusinessModules'
  spec.version      = '0.0.1'
  spec.authors      = { 
    'Hasan KACAR' => 'hasankacar@thy.com'
  }
  spec.license      = { 
    :type => 'MIT',
    :file => 'LICENSE' 
  }
  spec.homepage     = 'https://github.com/turkishtechnicmobile/TTBusinessModules'
  spec.source       = { 
    :git => 'https://github.com/turkishtechnicmobile/TTBusinessModules.git', 
    :branch => 'master',
    :tag => spec.version.to_s 
  }
  spec.summary      = 'test case for base frameworks'
  spec.source_files = '**/*.swift', '*.swift'
  spec.resources = '**/*.png', '*.png', '**/*.jpeg', '*.jpeg', '**/*.jpg', '*.jpg', '**/*.storyboard', '*.storyboard', '**/*.xib', '*.xib', '**/*.xcassets', '*.xcassets'
  spec.swift_versions = '4.2'
  spec.ios.deployment_target = '11.0'
  spec.dependency 'TTBaseModel', '~>0.0.1'
  spec.dependency 'TTBaseApp', '~>0.0.1'
  spec.dependency 'TTBaseService', '~>0.0.1'
  spec.dependency 'TTBaseView', '~>0.0.1'
end