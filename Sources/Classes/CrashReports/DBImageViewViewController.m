// The MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DBImageViewViewController.h"
#import "UIView+Snapshot.h"
#import "UIColor+QAToolkit.h"

@interface DBImageViewViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@end

@implementation DBImageViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    [self updateImage:self.image];
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBImageViewViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}

- (void)configureWithTitle:(NSString *)title image:(UIImage *)image {
    self.title = title;
    [self updateImage:image];
}

#pragma mark - Private methods

- (void)updateImage:(UIImage *)image {
    self.image = image;
    self.imageView.image = image;
}

@end
