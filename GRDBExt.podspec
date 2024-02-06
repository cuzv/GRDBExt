Pod::Spec.new do |s|
  s.name             = 'GRDBExt'
  s.version          = '1.0.0'

  s.summary          = s.name
  s.homepage         = 'https://github.com/cuzv'
  s.license          = 'MIT'
  s.author           = 'Shaw'
  s.source           = { :path => '.' }

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  # s.watchos.deployment_target = "5.0"
  # s.tvos.deployment_target = "12.0"
  # s.visionos.deployment_target = "1.0"
  s.swift_versions = '5.9'
  s.source_files = 'Sources/**/*.swift'

  s.dependency 'GRDB.swift', '~> 6.24.1'
end
