//
//  WebviewPreviewViewContoller.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 11/27/17.

//

#import <Foundation/Foundation.h>
#import "WebviewPreviewViewContoller.h"
#import "UIColor+QAToolkit.h"

@interface WebviewPreviewViewContoller () <WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, copy) NSString *storedPath;
@end


@implementation WebviewPreviewViewContoller

- (id)initWithPath:(NSString*) path{
    self = [super init];
    
    if (self) {
        self.storedPath = path;
        self.webView = [[WKWebView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.storedPath lastPathComponent];
    
    //WKWebViewConfiguration *config = [WKWebViewConfiguration alloc];
    //self.webView = [[WKWebView alloc] initWithFrame:self.accessibilityFrame configuration:config];
    
    [self.view addSubview:self.webView];
    
    [self viewWillLayoutSubview];
    //WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    //WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
   // webView.navigationDelegate = self;
    //NSURL *nsurl=[NSURL URLWithString:@"http://www.apple.com"];
    //NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    //[webView loadRequest:nsrequest];
   // [self.view addSubview:webView];
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[WebviewPreviewViewContoller class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];

    [self setupShareButton];
}

#pragma mark – share

- (void)setupShareButton {
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItem = shareItem;
}

- (void)share:(id)sender {
    NSArray *activityItems = @[[NSURL fileURLWithPath:self.storedPath]];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)viewWillLayoutSubview{
    
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
    
    [self processForDisplay];
}


- (void)processForDisplay{
    //check
    
    if (self.storedPath == nil) {
        return;
    }

    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.storedPath]];
    NSString *rawString;
    
    if([[[NSURL fileURLWithPath:self.storedPath] pathExtension] isEqual:@"plist"]){
        
        NSPropertyListSerialization *plistDescr = [NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:nil error:nil];
        rawString = plistDescr.description;
    
    }
    
    if([[[NSURL fileURLWithPath:self.storedPath] pathExtension] isEqual:@"json"]){
        NSJSONSerialization *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if ([NSJSONSerialization isValidJSONObject:jsonObject]){
            NSData *prettyJSON = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:prettyJSON encoding:kCFStringEncodingUTF8];
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            rawString = jsonString;
        }
    }
    if (rawString == nil){
        rawString = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
    }
    
    NSString *convertedString = [self convertSpecialCharacters:rawString];
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='initial-scale=1.0, user-scalable=no'></head><body><pre style=\"white-space: pre-wrap\">\%@</pre></body></html>" ,convertedString];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (NSString *)convertSpecialCharacters:(NSString *)string {
   
    if (string == nil) {
         NSLog(@"String is null");
        return nil;
    }
    NSString *newString = string;
    NSDictionary *char_dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"&",@"&amp",@"<",@"&lt",@">",@"&gt",@"\"",@"&quot",@"'",@"&apos", nil];
    NSArray *keys = [char_dictionary allKeys];
    NSArray *values = [char_dictionary allValues];
    for (NSUInteger i=0;i<keys.count;i++){
        [newString stringByReplacingOccurrencesOfString:keys[i] withString:values[i]];
    }
    return newString;
}

@end
