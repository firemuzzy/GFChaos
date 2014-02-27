Pod::Spec.new do |s|
  s.name = 'GFChaos'
  s.version = '0.0.1'
  s.platform = :ios
  s.ios.deployment_target = '5.0'
  s.prefix_header_file = 'GFChaos/GFChaos/GFChaos-Prefix.pch'
  s.source_files = 'GFChaos/GFChaos/*.{h,m}'
  s.requires_arc = true
  s.dependency 'ReactiveCocoa'
end
