Pod::Spec.new do |s|
  s.name             = 'Crypto'
  s.version          = '0.1.0'
  s.summary          = 'Crypto'
  s.description      = "Crypto"
  s.homepage         = 'https://github.com/foxterm/Crypto'
  s.license          = 'MIT'
  s.author           = { 'foxterm' => 'admin@foxterm.app' }
  s.source           = { :git => 'https://github.com/foxterm/Crypto.git', :tag => s.version.to_s }
  s.ios.deployment_target = '17.0'
  s.osx.deployment_target = '14.0'
  s.swift_version = '5.10'
  s.source_files = ['Sources/**/*.{swift,h,c}']
  s.dependency 'libetos'
  s.dependency 'Extension'
  s.dependency 'OpenSSL-Universal'
end
