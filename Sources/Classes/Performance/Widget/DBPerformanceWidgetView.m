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

#import "DBPerformanceWidgetView.h"
#import "UIColor+QAToolkit.h"
#import "NSObject+QAToolkit.h"

static const CGFloat DBPerformanceWidgetViewWidth = 220;
static const CGFloat DBPerformanceWidgetViewHeight = 50;
static const CGFloat DBPerformanceWidgetMinimalOffset = 10;

@interface DBPerformanceWidgetView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
- (void)fixZPosition;
@end

__weak UIWindow* gWindow = nil;
__weak DBPerformanceWidgetView* gWidget = nil;

@implementation UIWindow(QATLK)

- (void)qatlk_addSubview:(UIView *)view {
    [self qatlk_addSubview:view];

    if ( gWindow == self && gWidget) {
        if (view != gWidget) {
            [gWidget fixZPosition];
        }
    }
}

- (void)qatlk_insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [self qatlk_insertSubview:view atIndex:index];

    if (gWindow == self && gWidget) {
        [gWidget fixZPosition];
    }
}

- (void)qatlk_insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    [self qatlk_insertSubview:view aboveSubview:siblingSubview];

    if (gWindow == self && gWidget) {
        [gWidget fixZPosition];
    }
}

- (void)qatlk_insertSubview:(UIView *)view belowSubview:(nonnull UIView *)siblingSubview {
    [self qatlk_insertSubview:view belowSubview:siblingSubview];

    if (gWindow == self && gWidget) {
        [gWidget fixZPosition];
    }
}

@end

@implementation DBPerformanceWidgetView

+ (void)load {
    [[UIWindow class] exchangeInstanceMethodsWithOriginalSelector:@selector(addSubview:)
                                  andSwizzledSelector:@selector(qatlk_addSubview:)];
    [[UIWindow class] exchangeInstanceMethodsWithOriginalSelector:@selector(insertSubview:atIndex:)
                                  andSwizzledSelector:@selector(qatlk_insertSubview:atIndex:)];
    [[UIWindow class] exchangeInstanceMethodsWithOriginalSelector:@selector(insertSubview:aboveSubview:)
                                  andSwizzledSelector:@selector(qatlk_insertSubview:aboveSubview:)];
    [[UIWindow class] exchangeInstanceMethodsWithOriginalSelector:@selector(insertSubview:belowSubview:)
                                  andSwizzledSelector:@selector(qatlk_insertSubview:belowSubview:)];
}

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {

    gWidget = self;

    self.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self registerForNotifications];
    [self setupGestureRecognizers];
    
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBPerformanceWidgetView class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fixZPosition {

    if (!self.superview) {
        return;
    }

    @autoreleasepool {
        if ([[self.superview subviews] lastObject] != self) {
            [self.superview bringSubviewToFront:self];
        }
    }
}

#pragma mark - Adding to window

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!self.window) {
        // Setting up the default frame.
        self.frame = [self defaultFrameWithWindow:newWindow];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self updateFrame];

    if (gWidget == self) {
        gWindow = self.window;
    }

    [self fixZPosition];
}

#pragma mark - Updating frame

- (void)updateFrame {
    CGSize windowBoundsSize = self.window.bounds.size;
    CGRect frame = self.frame;
    frame.size.width = DBPerformanceWidgetViewWidth;
    frame.size.height = DBPerformanceWidgetViewHeight;
    frame.origin.x = MIN(windowBoundsSize.width - frame.size.width - DBPerformanceWidgetMinimalOffset,
                         MAX(DBPerformanceWidgetMinimalOffset, frame.origin.x));
    frame.origin.y = MIN(windowBoundsSize.height - frame.size.height - DBPerformanceWidgetMinimalOffset,
                         MAX(DBPerformanceWidgetMinimalOffset, frame.origin.y));
    self.frame = frame;
}

- (void)updateFrameWithNewOrigin:(CGPoint)newOrigin {
    self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
    [self updateFrame];
}

- (CGRect)defaultFrameWithWindow:(UIWindow *)window {
    CGSize windowBoundsSize = window.bounds.size;
    CGRect frame = CGRectZero;
    frame.size.width = DBPerformanceWidgetViewWidth;
    frame.size.height = DBPerformanceWidgetViewHeight;
    frame.origin.x = (windowBoundsSize.width - frame.size.width) / 2;
    frame.origin.y = windowBoundsSize.height - frame.size.height - DBPerformanceWidgetMinimalOffset;
    return frame;
}

#pragma mark - Rotation notifications

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidChangeOrientation:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)deviceDidChangeOrientation:(NSNotification *)notification {
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        // The widget view was added directly to the window, so it needs custom rotation handling.
        [self updateFrame];
    }
}

#pragma mark - Gesture recognizers

- (void)setupGestureRecognizers {
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint tapLocation = [tapGestureRecognizer locationInView:self];
        DBPerformanceSection tappedSection;
        if (tapLocation.x < self.frame.size.width / 3) {
            tappedSection = DBPerformanceSectionCPU;
        } else if (tapLocation.x < 2 * self.frame.size.width / 3) {
            tappedSection = DBPerformanceSectionMemory;
        } else {
            tappedSection = DBPerformanceSectionFPS;
        }
        [self.delegate performanceWidgetView:self didTapOnSection:tappedSection];
    }
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    static CGPoint previousTouchLocation;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        previousTouchLocation = [panGestureRecognizer locationInView:self.window];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint currentTouchLocation = [panGestureRecognizer locationInView:self.window];
        CGFloat xDifference = currentTouchLocation.x - previousTouchLocation.x;
        CGFloat yDifference = currentTouchLocation.y - previousTouchLocation.y;
        CGPoint newOrigin = CGPointMake(self.frame.origin.x + xDifference,
                                        self.frame.origin.y + yDifference);
        previousTouchLocation = currentTouchLocation;
        [self updateFrameWithNewOrigin:newOrigin];
    }
}

@end
