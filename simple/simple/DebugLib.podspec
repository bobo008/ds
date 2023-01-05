

Pod::Spec.new do |s|
    s.name             = 'DebugLib'
    s.version          = '1.0.3'
    s.summary          = 'debug组件'
        
    s.description      = <<-DESC
        debug组件，基本上每个项目都可以用到的东西。
    DESC
    
    s.homepage         = 'http://gitlab.ad.com/gzyspecs/gzypods/debuglib'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'thb' => '1030831926@qq.com' }
    s.source           = { :git => 'http://gitlab.ad.com/gzyspecs/gzypods/debuglib.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '11.0'
    

    s.source_files = 'DebugLib/Classes/*'


          
end
