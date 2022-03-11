Pod::Spec.new do |s|
  s.name = "QAToolkit"
  s.version = "2.4.0"
  s.summary = "Debugging tools for iOS developers & QA engineers."

  s.description = "QA toolkit framework"
  s.license = { :type => 'CUSTOM', :file => 'LICENSE' }
  s.homepage = "https://github.com/ladeiko/QAToolkit"
  s.author = "Developers"
  s.source = { :git => 'https://github.com/ladeiko/QAToolkit.git', :tag => s.version.to_s }
  s.swift_versions = "4.0", "4.2", "5.0", "5.1", "5.2", "5.3", "5.4", "5.5"
  s.ios.deployment_target = "11.0"

  s.source_files = "Sources/**/*.{h,swift,m}", "Sources/QAToolkit.h", "Sources/QAToolkit.m"

  s.resource_bundles = {
    "QAToolkit" => ["Sources/Resources/*.{storyboard,xib,bundle,xcassets}"],
  }

  s.pod_target_xcconfig = {
    "USER_HEADER_SEARCH_PATHS" => '"$PODS_ROOT/QAToolkit/Sources/Classes/Resources/Receipt"',
  }

  s.dependency "TPInAppReceipt", ">= 3.1.0"
  s.dependency "TopViewControllerDetection"
end
