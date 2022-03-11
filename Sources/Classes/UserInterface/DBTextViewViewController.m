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

#import "DBTextViewViewController.h"
#import "UIColor+QAToolkit.h"

@interface DBTextViewViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewWidthConstraint;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL isInConsoleMode;

@end

@implementation DBTextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    [self updateText:self.text];
    [self modeSetup];
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBTextViewViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];

}

- (void)configureWithTitle:(NSString *)title text:(NSString *)text isInConsoleMode:(BOOL)isInConsoleMode {
    self.title = title;
    self.isInConsoleMode = isInConsoleMode;
    [self updateText:text];
}

#pragma mark - Private methods

- (void)updateText:(NSString *)text {
    self.text = text;
    self.textView.text = text;
}

- (void)modeSetup {
    if (self.isInConsoleMode) {
        self.textView.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    } else {
        self.textView.font = [UIFont systemFontOfSize:14];
        self.textViewWidthConstraint.active = NO;
    }
}

@end
