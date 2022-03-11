//
//  FilePreviewController.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 11/24/17.

//

#import <Foundation/Foundation.h>
#import "FilePreviewController.h"
#import "UIColor+QAToolkit.h"
@import QuickLook;

@interface FilePreviewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, copy) NSString* pptPath;
@end

@implementation FilePreviewController

- (id)initWithPath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        self.pptPath = filePath;
    }
    return self;
}

- (void)share {
    NSURL* const url = [NSURL fileURLWithPath:self.pptPath];
    UIActivityViewController* const controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];

    [self presentViewController:controller animated:YES completion:nil];

    if (controller.popoverPresentationController) {
        controller.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(share)];

    QLPreviewController *previewController=[[QLPreviewController alloc]init];
    previewController.delegate=self;
    previewController.dataSource=self;
    [previewController setAccessibilityValue:self.pptPath];

    self.title = [self.pptPath lastPathComponent];

    [self addChildViewController:previewController];
    previewController.view.frame = self.view.bounds;
    previewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:previewController.view];
    [previewController didMoveToParentViewController:self];

    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[FilePreviewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}

#pragma mark - data source methods

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.pptPath];
}

#pragma mark - delegate methods

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

@end

