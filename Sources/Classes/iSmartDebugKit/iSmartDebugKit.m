//
//  iSmartDebugKit.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 6/1/18.
//  Updated by Siarhei Ladzeika.

//

#import <Foundation/Foundation.h>

#import "iSmartDebugKit.h"
#import <QAToolkit/QAToolkit.h>
#import "QATSmartCustomVariable.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+QAToolkit.h"
#import <TopViewControllerDetection/TopViewControllerDetection-Swift.h>

@interface iSmartDebugKit(Private)
+ (void)addBannerMessage:(NSString*)message;
@end

@implementation iSmartDebugKitBlock

+ (instancetype)blockWithBlock:(id)block
{
    iSmartDebugKitBlock* action = iSmartDebugKit_ARC_AUTORELEASE([iSmartDebugKitBlock new]);
    if (action)
    {
#if iSmartDebugKit_uses_arc
        action.actionBlock = block;
#else
        action->_actionBlock = Block_copy(block);
#endif
    }
    return action;
}

#if !iSmartDebugKit_uses_arc
- (void)dealloc
{
    if (_actionBlock)
        Block_release(_actionBlock);
    [super dealloc];
}
#endif

@end


NSString* iSmartDebugKitDidChangeApplicationLocaleNotification = @"iSmartDebugKitDidChangeApplicationLocaleNotification";
NSString* iSmartDebugKitTunableVariableTypeKey = @"iSmartDebugKitTunableVariableTypeKey";
NSString* iSmartDebugKitTunableVariableMinValueKey = @"iSmartDebugKitTunableVariableMinValueKey";
NSString* iSmartDebugKitTunableVariableMaxValueKey = @"iSmartDebugKitTunableVariableMaxValueKey";
NSString* iSmartDebugKitTunableVariableRangeValueKey = @"iSmartDebugKitTunableVariableRangeValueKey";
NSString* iSmartDebugKitTunableVariableSetterKey = @"iSmartDebugKitTunableVariableSetterKey";
NSString* iSmartDebugKitTunableVariableGetterKey = @"iSmartDebugKitTunableVariableGetterKey";
NSString* iSmartDebugKitTunableVariableNameKey = @"iSmartDebugKitTunableVariableNameKey";
NSString* const iSmartDebugKitTunableVariableAllowedKey = @"iSmartDebugKitTunableVariableAllowedKey";

NSString* iSmartDebugKitCustomActionNameKey = @"iSmartDebugKitCustomActionNameKey";
NSString* iSmartDebugKitCustomActionsListDidChangeNotification = @"iSmartDebugKitCustomActionsListDidChangeNotification";
NSString* iSmartDebugKitTunableVariablesListDidChangeNotification = @"iSmartDebugKitTunableVariablesListDidChangeNotification";
NSString* iSmartDebugKitTunableVariableValueDidChangeNotification = @"iSmartDebugKitTunableVariableValueDidChangeNotification";

@interface QATMPBannerDelegate : NSObject {}
@property (copy, nonatomic) NSString* adapterName;
@property (weak, nonatomic) NSObject* delegate;
@end

static NSString* lastText = @"- nothing -";
static UILabel* messageView = nil;
static BOOL showMoPubBannerInfo = NO;
static NSMutableSet<NSString*>* trackedAdapters = nil;

@interface UILabel(QAToolkit)
- (void)qat_scrollLabel;
- (void)qat_scrollLabelStop;
@end

static const char timerKey;
static const char lastTextKey;

@implementation UILabel(QAToolkit)

- (void)qat_scrollLabel {

    if (objc_getAssociatedObject(self, &timerKey)){
        return;
    }

    __weak UILabel* sself = self;
    __block NSString* lastText = [sself text];

    objc_setAssociatedObject(self, &lastTextKey, lastText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSString* text = [sself text];
        if ([text length] > 0) {
            text = [text substringFromIndex:1];
            [sself setText:text];
        }
        else {
            [timer invalidate];
            objc_setAssociatedObject(self, &timerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [sself setText:lastText];
        }
    }];

    objc_setAssociatedObject(self, &timerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)qat_scrollLabelStop {
    [objc_getAssociatedObject(self, &timerKey) invalidate];
    objc_setAssociatedObject(self, &timerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setText:objc_getAssociatedObject(self, &lastTextKey)];
}

@end


static void show(NSString* text) {

    if (!text) {
        text = @"";
    }

    lastText = [text copy];

    if (!showMoPubBannerInfo) {
        return;
    }

    if (!messageView) {
        const CGFloat h = 15;
        messageView = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                [[[UIApplication sharedApplication] keyWindow] bounds].size.height - h,
                                                                [[[UIApplication sharedApplication] keyWindow] bounds].size.width,
                                                                h)];
        messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        messageView.textAlignment = NSTextAlignmentLeft;
        messageView.font = [UIFont systemFontOfSize:8];
        messageView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        messageView.layer.borderColor = [UIColor blackColor].CGColor;
        messageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        messageView.textColor = [UIColor blackColor];
        messageView.userInteractionEnabled = YES;

        [messageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:messageView action:@selector(qat_scrollLabel)]];
        [messageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:messageView action:@selector(qat_scrollLabelStop)]];

        [[[UIApplication sharedApplication] keyWindow] addSubview:messageView];
    }
    else {
        [messageView.superview bringSubviewToFront:messageView];
    }

    messageView.text = text;
}

static void hide() {
    if (messageView) {
        [messageView removeFromSuperview];
        messageView = nil;
    }
}

static void restoreShow() {

    if (messageView) {
        return;
    }

    show(lastText);
}

@implementation QATMPBannerDelegate

- (void)forwardInvocation:(NSInvocation *)anInvocation {

    SEL selector = [anInvocation selector];

    if (selector == NSSelectorFromString(@"inlineAdAdapter:didLoadAdWithAdView:")) {
        NSString* const message = [NSString stringWithFormat:@"%@ OK", self.adapterName];
        show(message);
        [iSmartDebugKit addBannerMessage:message];
    }
    else if (selector == NSSelectorFromString(@"inlineAdAdapter:didFailToLoadAdWithError:")) {
        __unsafe_unretained NSError* error;
        [anInvocation getArgument:&error atIndex:3];
        NSString* const message = [NSString stringWithFormat:@"%@ ERR: %@", self.adapterName, [error localizedDescription]];
        show(message);
        [iSmartDebugKit addBannerMessage:message];
    }
    else if (selector == NSSelectorFromString(@"adViewDidLoadAd:adSize:")) {
        NSString* const message = [NSString stringWithFormat:@"%@ OK", self.adapterName];
        show(message);
        [iSmartDebugKit addBannerMessage:message];
    }
    else if (selector == NSSelectorFromString(@"adView:didFailToLoadAdWithError:")) {
        __unsafe_unretained NSError* error;
        [anInvocation getArgument:&error atIndex:3];
        if ([[error domain] isEqualToString:@"com.mopub.iossdk"] && [error code] == 0) {
            NSString* const message = [NSString stringWithFormat:@"%@ No ads", self.adapterName];
            show(message);
            [iSmartDebugKit addBannerMessage:message];
        }
        else {
            NSString* const message = [NSString stringWithFormat:@"%@ ERR: %@", self.adapterName, [error localizedDescription]];
            show(message);
            [iSmartDebugKit addBannerMessage:message];
        }
    }

    if ([self.delegate respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.delegate];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {

    // Check if car can handle the message
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];

    // If not, can the car info string handle the message?
    if (!signature)
        signature = [self.delegate methodSignatureForSelector:aSelector];

    return signature;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {

    if ( [super conformsToProtocol:protocol] )
        return YES;

    return [self.delegate conformsToProtocol:protocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector {

    if ( [super respondsToSelector:aSelector] )
        return YES;

    return [self.delegate respondsToSelector:aSelector];
}

@end

@interface iSmartDebugKit () {
    NSMutableDictionary* tunableValues_;
    NSMutableDictionary* customActions_;
}
@end

static NSMutableArray* bannerLogs = nil;

@implementation iSmartDebugKit

// NOT IMPLEMENTED
+ (void)load
{
    //TODO: launch time
    //TODO: console file

    dispatch_async(dispatch_get_main_queue(), ^{
        [iSmartDebugKit defaultKit];
    });
}

+ (void)addBannerMessage:(NSString*)message {

    if (!bannerLogs) {
        bannerLogs = [NSMutableArray new];
    }

    [bannerLogs addObject:message];

    while ([bannerLogs count] > 50) {
        [bannerLogs removeObjectAtIndex:0];
    }
}

- (void)hookBannerClass:(Class)class {

    if (!class) {
        return;
    }

    NSString* className = NSStringFromClass(class);
    if (!trackedAdapters) {
        trackedAdapters = [NSMutableSet new];
    }

    if ([trackedAdapters containsObject:className]) {
        return;
    }

    [trackedAdapters addObject:className];

    const SEL requestAdWithSizeSEL = NSSelectorFromString(@"requestAdWithSize:adapterInfo:adMarkup:");

    if (class_getInstanceMethod(class, requestAdWithSizeSEL)) {

        static const int k = 0;

        __block IMP requestAdWithSizeIMP = [class replaceMethodWithSelector:requestAdWithSizeSEL block:^(id _self, CGSize size, NSDictionary* info, NSString * adMarkup) {

            ((void (*)(id, SEL, CGSize, NSDictionary*, NSString*))requestAdWithSizeIMP)(_self, requestAdWithSizeSEL, size, info, adMarkup);

            id delegate = ((id (*)(id, SEL))objc_msgSend)(_self, NSSelectorFromString(@"delegate"));

            NSString* const message = [NSString stringWithFormat:@"%@ Loading...", className];
            [iSmartDebugKit addBannerMessage:message];

            show(message);

            if (delegate && ![delegate isKindOfClass:[QATMPBannerDelegate class]]) {
                QATMPBannerDelegate* const del = [QATMPBannerDelegate new];
                del.adapterName = NSStringFromClass([_self class]);
                objc_setAssociatedObject(_self, &k, del, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                del.delegate = delegate;
                ((id (*)(id, SEL, id))objc_msgSend)(_self, NSSelectorFromString(@"setDelegate:"), del);
            }
        }];
    }

    if (class_getInstanceMethod(class, NSSelectorFromString(@"loadAd"))) {
        static const int k = 0;

        __block IMP requestAdWithSizeIMP = [class replaceMethodWithSelector:NSSelectorFromString(@"loadAd") block:^(id _self) {

            ((void (*)(id, SEL))requestAdWithSizeIMP)(_self, requestAdWithSizeSEL);

            id delegate = ((id (*)(id, SEL))objc_msgSend)(_self, NSSelectorFromString(@"delegate"));

            NSString* const adapterName = @"MPAdView";

            NSString* const message = [NSString stringWithFormat:@"%@ Loading...", adapterName];
            [iSmartDebugKit addBannerMessage:message];

            show(message);

            if (delegate && ![delegate isKindOfClass:[QATMPBannerDelegate class]]) {
                QATMPBannerDelegate* const del = [QATMPBannerDelegate new];
                del.adapterName = adapterName;
                objc_setAssociatedObject(_self, &k, del, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                del.delegate = delegate;
                ((id (*)(id, SEL, id))objc_msgSend)(_self, NSSelectorFromString(@"setDelegate:"), del);
            }
        }];
    }
}

- (void)trackMoPubBannerAdapter:(Class)adapterClass {
    [self hookBannerClass:adapterClass];
}

- (id)init
{
    self = [super init];

    if (self)
    {
        tunableValues_ = [[NSMutableDictionary alloc] init];
        customActions_ = [[NSMutableDictionary alloc] init];

        // clear cache is already integrated.

        dispatch_async(dispatch_get_main_queue(), ^{

            [@[
                @"AdColonyBannerCustomEvent",
                @"AppLovinBannerCustomEvent",
                @"ChartboostBannerCustomEvent",
                @"FacebookBannerCustomEvent",
                @"InMobiBannerCustomEvent",
                @"InneractiveBannerCustomEvent",
                @"MintegralBannerCustomEvent",
                @"MPGoogleAdMobBannerCustomEvent",
                @"MPHTMLBannerCustomEvent",
                @"MPVerizonBannerCustomEvent",
                @"UnityAdsBannerCustomEvent",
                @"VungleBannerCustomEvent",
                @"MPAdView",
            ] enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self hookBannerClass:NSClassFromString(obj)];
            }];

            [self addTunableBooleanNamed:@"Show MoPub Banner Info" setter:^(BOOL value) {
                showMoPubBannerInfo = value;
                if (!showMoPubBannerInfo) {
                    hide();
                }
                else {
                    restoreShow();
                }
            } getter:^BOOL{
                return showMoPubBannerInfo;
            }];

            [self setupSmartAttributionSupport];

            [self addCustomAction:^{

                NSMutableAttributedString* finalMessage = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{}];

                const CGFloat fontSize = 10;
                if ([bannerLogs count] == 0) {
                    NSAttributedString* const n1 = [[NSAttributedString alloc] initWithString:@"No logs" attributes:@{
                        NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
                        NSForegroundColorAttributeName: [UIColor lightGrayColor],
                    }];

                    [finalMessage appendAttributedString:n1];
                }
                else {

                    [bannerLogs enumerateObjectsUsingBlock:^(NSString*  _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {

                        NSAttributedString* const n1 = [[NSAttributedString alloc] initWithString:@"* " attributes:@{
                            NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]
                        }];

                        [finalMessage appendAttributedString:n1];

                        NSAttributedString* const n2 = [[NSAttributedString alloc] initWithString:[entry stringByAppendingString:@"\n"] attributes:@{
                            NSFontAttributeName: [UIFont systemFontOfSize:fontSize]
                        }];

                        [finalMessage appendAttributedString:n2];

                    }];
                }

                UIAlertController* const alertController = [UIAlertController alertControllerWithTitle:@"Mopub Banners Logs"
                                                                                               message:[finalMessage string]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

                if ([bannerLogs count] > 0) {
                    NSMutableParagraphStyle* const style = [NSMutableParagraphStyle new];
                    style.alignment = NSTextAlignmentLeft;
                    [finalMessage addAttributes:@{ NSParagraphStyleAttributeName: style } range:NSMakeRange(0, [finalMessage length])];
                }

                [alertController setValue:finalMessage forKey: @"attributedMessage"];

                [[UIApplication sharedApplication] findTopViewController:^(UIViewController * _Nullable topController) {
                    if (topController) {
                        [topController presentViewController:alertController animated:YES completion:nil];
                    }
                }];

            } named:@"Show Mopub banners logs"];

        });
    }

    return self;
}

-(void) dealloc {
    iSmartDebugKit_ARC_SUPER_DEALLOC();
}

+ (iSmartDebugKit*)defaultKit
{
    static iSmartDebugKit* shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[iSmartDebugKit alloc] init];
    });
    return shared;
}

- (void)setupSmartAttributionSupport {
    Class const iSmartAttributionClass = NSClassFromString(@"iSmartAttribution");
    if (iSmartAttributionClass) {
        [self addCustomAction:^{

            id (* const shared)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
            const SEL sharedSel = NSSelectorFromString(@"shared");
            const id sharedInstance = shared(iSmartAttributionClass, sharedSel);
            const SEL allVariablesSel = NSSelectorFromString(@"allVariables");

            NSDictionary<NSString*, NSString*>* (* const allVariables)(id, SEL) = (NSDictionary<NSString*, NSString*>* (*)(id, SEL))objc_msgSend;
            NSDictionary<NSString*, NSString*>* const variables = allVariables(sharedInstance, allVariablesSel);
            NSMutableString* const message = [NSMutableString new];

            [[[variables allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] enumerateObjectsUsingBlock:^(NSString * _Nonnull variableName, NSUInteger idx, BOOL * _Nonnull stop) {
                [message appendFormat:@"%@: %@\n", variableName, [variables objectForKey:variableName]];
            }];

            UIAlertController* const alertController = [UIAlertController alertControllerWithTitle:@"Smart Attributiob"
                                                                                           message:message
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

            [[UIApplication sharedApplication] findTopViewController:^(UIViewController * _Nullable topController) {
                if (topController) {
                    [topController presentViewController:alertController animated:YES completion:nil];
                }
            }];
        } named:@"Show SmartAttribution variables"];
    }
}

- (void)addTunableBooleanNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableBooleanValueSetter)_setter
                        getter:(iSmartDebugKitTunableBooleanValueGetter)_getter
{
    bool initialValue = false;
    if (_getter) {
        initialValue = _getter();
    }
    QATSmartCustomVariable* customVar = [QATSmartCustomVariable customVariableWithName:_named
                                                                                 value:[NSNumber numberWithBool:initialValue]
                                                                               minimum:nil
                                                                               maximum:nil
                                                                                getter: [iSmartDebugKitBlock blockWithBlock:_getter]
                                                                                setter: [iSmartDebugKitBlock blockWithBlock:_setter]
                                                                                 range:nil];
    [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];
}




- (void)addTunableIntegerNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableIntegerValueSetter)_setter
                        getter:(iSmartDebugKitTunableIntegerValueGetter)_getter
                      minValue:(int)_minValue
                      maxValue:(int)_maxValue
{
    NSNumber* initialVal = nil;
    if (_getter) {
        initialVal = [NSNumber numberWithInt:_getter()];
    } else {
        initialVal =  [NSNumber numberWithInt:INT_MAX];
    }

    QATSmartCustomVariable* customVar = [QATSmartCustomVariable customVariableWithName:_named
                                                                                 value:initialVal
                                                                               minimum:[NSNumber numberWithInt:_minValue]
                                                                               maximum:[NSNumber numberWithInteger:_maxValue]
                                                                                getter: [iSmartDebugKitBlock blockWithBlock:_getter]
                                                                                setter: [iSmartDebugKitBlock blockWithBlock:_setter]
                                                                                 range:nil];


    //DBCustomVariable* customVar = [DBCustomVariable customVariableWithNameMinMax:_named value:initialVal min:[NSNumber numberWithDouble:_minValue] max:[NSNumber numberWithDouble:_maxValue]];
     [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];
}


- (void)addTunableDoubleNamed:(NSString*)_named
                       setter:(iSmartDebugKitTunableDoubleValueSetter)_setter
                       getter:(iSmartDebugKitTunableDoubleValueGetter)_getter
                     minValue:(double)_minValue
                     maxValue:(double)_maxValue
{
    NSNumber* initialVal = nil;
    if (_getter) {
        initialVal = [NSNumber numberWithDouble:_getter()];
    } else {
        initialVal =  [NSNumber numberWithDouble:NAN];
    }

    QATSmartCustomVariable* customVar = [QATSmartCustomVariable customVariableWithName:_named
                                                                                 value:initialVal
                                                                               minimum:[NSNumber numberWithDouble:_minValue]
                                                                               maximum:[NSNumber numberWithDouble:_maxValue]
                                                                                getter: [iSmartDebugKitBlock blockWithBlock:_getter]
                                                                                setter: [iSmartDebugKitBlock blockWithBlock:_setter]
                                                                            range:nil];

    //DBCustomVariable* customVar = [DBCustomVariable customVariableWithNameMinMax:_named value:initialVal min:[NSNumber numberWithDouble:_minValue] max:[NSNumber numberWithDouble:_maxValue]];

    [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];
}


-(void) addTunableFloatNamed:(NSString *)_named setter:(iSmartDebugKitTunableFloatValueSetter)_setter getter:(iSmartDebugKitTunableFloatValueGetter)_getter minValue:(float)_minValue maxValue:(float)_maxValue
{

    iSmartDebugKitTunableDoubleValueSetter doubleSetter = ^(double val){_setter((double)val); };
    iSmartDebugKitTunableDoubleValueGetter doubleGetter = ^double{return (double)_getter(); };

    return [self addTunableDoubleNamed:_named
                                setter:doubleSetter
                                getter:doubleGetter
                              minValue:_minValue maxValue:_maxValue];
}

//NEED VERIFICATION
- (void)addTunableIntegerNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableIntegerValueSetter)_setter
                        getter:(iSmartDebugKitTunableIntegerValueGetter)_getter
                         range:(NSArray*)_range
{
    NSNumber* initialVal = nil;
    if (_getter) {
        initialVal = [NSNumber numberWithInt:_getter()];
    } else {
        initialVal =  _range[0];
    }

    QATSmartCustomVariable* customVar = [QATSmartCustomVariable customVariableWithName:_named value:initialVal minimum:nil maximum:nil getter:[iSmartDebugKitBlock blockWithBlock:_getter] setter:[iSmartDebugKitBlock blockWithBlock:_setter] range:_range];

   //DBCustomVariable* customVar = [DBCustomVariable customVariableWithNameRange:_named value:initialVal range:_range];
    [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];
}


- (void)addTunableIntegerNamed:(NSString*)_named
                        setter:(iSmartDebugKitTunableIntegerValueSetter)_setter
                        getter:(iSmartDebugKitTunableIntegerValueGetter)_getter
{

    NSNumber* initialVal = nil;
    if (_getter) {
        initialVal = [NSNumber numberWithInt:_getter()];
    } else {
        initialVal =  [NSNumber numberWithInt:INT_MAX];
    }

    QATSmartCustomVariable* customVar = [QATSmartCustomVariable customVariableWithName:_named
                                                                                 value:initialVal
                                                                               minimum:nil
                                                                               maximum:nil
                                                                                getter: [iSmartDebugKitBlock blockWithBlock:_getter]
                                                                                setter: [iSmartDebugKitBlock blockWithBlock:_setter]
                                                                                 range:nil];


    //DBCustomVariable* customVar = [DBCustomVariable customVariableWithNameMinMax:_named value:initialVal min:[NSNumber numberWithDouble:_minValue] max:[NSNumber numberWithDouble:_maxValue]];
    [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];
}


- (void)addTunableStringSwitchNamed:(NSString*)_named
                             setter:(iSmartDebugKitTunableStringValueSetter)_setter
                             getter:(iSmartDebugKitTunableStringValueGetter)_getter
                            allowed:(NSArray*)values
{
    NSString* initialValue = nil;
    if (_getter) {
        initialValue = _getter();
    } else {
        initialValue =  values[0];
    }
    //NSString* initialValue = _getter();

    QATSmartCustomVariable *customVar = [QATSmartCustomVariable customVariableWithName:_named value:initialValue minimum:nil maximum:nil getter:[iSmartDebugKitBlock blockWithBlock:_getter] setter:[iSmartDebugKitBlock blockWithBlock:_setter] range:values];
    [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];

    //DBCustomVariable* customVar = [DBCustomVariable customVariableWithNameRange:_named value:initialValue range:values];

    //[self postTunableVariablesChangedNotification];
    //[QAToolkit addCustomVariable:customVar];
}

- (void)addTunableStringNamed:(NSString*)_named
                       setter:(iSmartDebugKitTunableStringValueSetter)_setter
                       getter:(iSmartDebugKitTunableStringValueGetter)_getter
{
    NSString* initialValue = nil;
    if (_getter) {
        initialValue = _getter();
    } else {
        initialValue =  @"NEL";
    }
    //NSString* initialValue = _getter();

    QATSmartCustomVariable *customVar = [QATSmartCustomVariable customVariableWithName:_named value:initialValue minimum:nil maximum:nil getter:[iSmartDebugKitBlock blockWithBlock:_getter] setter:[iSmartDebugKitBlock blockWithBlock:_setter] range:nil];
    [self postTunableVariablesChangedNotification];
    [QAToolkit addCustomVariable:customVar];
}


- (void)removeTunableVariableNamed:(NSString*)_name {
    [QAToolkit removeCustomVariableWithName:_name];
    [self postTunableVariablesChangedNotification];
}

- (void)addPersistentTunableBooleanNamed:(NSString*)name defaultValue:(BOOL)defaultValue {

    if (![self keyExists:name]) {
        [self saveBool:defaultValue forKey:name];
    }

    __weak iSmartDebugKit* wself = self;
    [self addTunableBooleanNamed:name setter:^(BOOL value) {
        [wself saveBool:value forKey:name];
    } getter:^BOOL{
        return [wself loadBoolForKey:name defaultsTo:defaultValue];
    }];
}

- (BOOL)tunableBooleanForName:(NSString*)name {
    return [self loadBoolForKey:name defaultsTo:NO];
}

- (BOOL)tunableBooleanForName:(NSString*)name defaultValue:(BOOL)defaultValue {
    return [self loadBoolForKey:name defaultsTo:defaultValue];
}

- (NSString*)persistentKeyFor:(NSString*)key {
    return [@"iSmartDebugKit_persistent_tunable_variable:" stringByAppendingString:key];
}

- (BOOL)keyExists:(NSString*)key {
    key = [self persistentKeyFor:key];
    return [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:key];
}

- (void)saveBool:(BOOL)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:[self persistentKeyFor:key]];
}

- (BOOL)loadBoolForKey:(NSString*)key defaultsTo:(BOOL)defaultValue {

    key = [self persistentKeyFor:key];

    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:key]){
        return defaultValue;
    }

    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)saveString:(NSString*)value forKey:(NSString*)key {
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:[self persistentKeyFor:key]];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self persistentKeyFor:key]];
    }
}

- (NSString*)loadStringForKey:(NSString*)key defaultsTo:(NSString*)defaultValue {

    key = [self persistentKeyFor:key];

    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:key]){
        return defaultValue;
    }

    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

- (void)saveInt:(NSInteger)value forKey:(NSString*)key {
    if (value) {
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:[self persistentKeyFor:key]];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self persistentKeyFor:key]];
    }
}

- (NSInteger)loadIntForKey:(NSString*)key defaultsTo:(NSInteger)defaultValue {

    key = [self persistentKeyFor:key];

    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:key]){
        return defaultValue;
    }

    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

- (void)refreshTunableVariableNamed:(NSString*)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iSmartDebugKitVarWasUpdated"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:name forKey:@"name"]];
}

- (void)addCustomAction:(iSmartDebugKitCustomAction)_action named:(NSString*)_named {
    DBCustomAction* action = [DBCustomAction customActionWithName:_named body:_action];
    [QAToolkit addCustomAction:action];

    [[NSNotificationCenter defaultCenter] postNotificationName:iSmartDebugKitCustomActionsListDidChangeNotification object:self];
}

/*!
 @brief Removes custom action with specified name.
 */

- (void)removeCustomActionNamed:(NSString*)_named {
    [QAToolkit removeCustomActionWithName:_named];

    [[NSNotificationCenter defaultCenter] postNotificationName:iSmartDebugKitCustomActionsListDidChangeNotification object:self];
}

- (void)postTunableVariablesChangedNotification
{
    //check later
    //NSAssert([NSThread isMainThread], @"Should called only from main thread!");

    [[NSNotificationCenter defaultCenter] postNotificationName:iSmartDebugKitTunableVariablesListDidChangeNotification
                                                        object:self];
}



/*! Hides opened debug kit panel */
- (void)hidePanel {
    [QAToolkit hideMenu];
}

/*! Show debug kit panel */
 - (void)showPanel {
    [QAToolkit showMenu];
 }

//CONF PRESET
+ (void) setConfigurationPresets:(NSArray<NSDictionary *>*) presets {
    [QAToolkit setConfigurationPresets:presets];
}


// ui implemented
- (void)setShakeEnabled:(BOOL)enable {

}


@end


