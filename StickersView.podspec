Pod::Spec.new do |s|

  s.name         = 'StickersView'
  s.version      = '1.1.0'
  s.license      = 'MIT'
  s.summary      = 'StickersView is a customized face box.'
  s.homepage     = 'https://github.com/AdelaToderici/StickersView'
  s.description  = 'StickersView is a customizable image processing for face recognition that can be used in iOS app.'
  s.author       = { 'Isabela Adela Toderici' => 'adeisa90@yahoo.com' }
  s.source       = { :git => 'https://github.com/AdelaToderici/StickersView.git', :tag => '1.1.0' }

  s.platform = :ios, '11.0'

  s.source_files  = "StickersView", "StickersView/**/*.{h,m,swift}"

  s.requires_arc = true

end