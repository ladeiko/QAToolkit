//
//  WebviewPreviewViewContoller.h
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 11/27/17.

//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebviewPreviewViewContoller : UIViewController
@property (nonatomic, strong) NSURL* pathToFile;
@property (nonatomic, strong) WKWebView *webView;
- (id)initWithPath:(NSString *)path;
@end
