Pod::Spec.new do |s|
  s.name         = "NMSliderViewController"
  s.version      = "0.0.1"
  s.summary      = "A sliding view controller container."
  s.homepage     = "https://github.com/pudgeball/NMSliderViewController"
  s.license      = {:type => 'BSD', :file => 'LICENSE'}
  s.author       = { "Nick McGuire" => "pudgeball@me.com" }
  s.source       = { :git => "https://github.com/pudgeball/NMSliderViewController.git", :tag => "0.0.1" }
  s.platform     = :ios, '5.0'
  s.source_files = 'NMSliderViewController'
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end
