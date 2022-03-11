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

#import "QAToolkit.h"
#import "DBShakeTrigger.h"
#import "DBMenuTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "DBPerformanceWidgetView.h"
#import "DBPerformanceToolkit.h"
#import "DBPerformanceTableViewController.h"
#import "DBConsoleOutputCaptor.h"
#import "DBNetworkToolkit.h"
#import "DBUserInterfaceToolkit.h"
#import "DBLocationToolkit.h"
#import "DBKeychainToolkit.h"
#import "DBUserDefaultsToolkit.h"
#import "DBCoreDataToolkit.h"
#import "DBCrashReportsToolkit.h"
#import "DBToolkitSettings.h"
#import "QATConfigurationPresetToolkit.h"

@interface NSArray (QAToolKit)
- (NSArray *)qatoolkit_mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
- (NSArray *)qatoolkit_thru:(NSArray* (^)(NSArray* obj))block;
@end

@implementation NSArray (QAToolKit)

- (NSArray *)qatoolkit_mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

- (NSArray *)qatoolkit_thru:(NSArray* (^)(NSArray* obj))block {
    return block(self);
}

@end

static NSString *const QAToolkitObserverPresentationControllerPropertyKeyPath = @"containerView";

@interface QAToolkit () <QAToolkitTriggerDelegate, DBMenuTableViewControllerDelegate, DBPerformanceWidgetViewDelegate, DBToolkitSettingsDelegate>

@property (nonatomic, copy) NSArray <id <QAToolkitTrigger>> *triggers;
@property (nonatomic, strong) DBMenuTableViewController *menuViewController;
@property (nonatomic, assign) BOOL showsMenu;
@property (nonatomic, strong) DBPerformanceToolkit *performanceToolkit;
@property (nonatomic, strong) DBConsoleOutputCaptor *consoleOutputCaptor;
@property (nonatomic, strong) DBNetworkToolkit *networkToolkit;
@property (nonatomic, strong) DBUserInterfaceToolkit *userInterfaceToolkit;
@property (nonatomic, strong) DBToolkitSettings *dbToolkitSettings;
@property (nonatomic, strong) DBLocationToolkit *locationToolkit;
@property (nonatomic, strong) DBCoreDataToolkit *coreDataToolkit;
@property (nonatomic, strong) DBCrashReportsToolkit *crashReportsToolkit;
@property (nonatomic, strong) QATConfigurationPresetToolkit *configurationPresetToolkit;
@property (nonatomic, strong, readonly) NSMutableArray <DBCustomAction *> *customActions;
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *, DBCustomVariable *> *customVariables;

@end

@implementation QAToolkit

#pragma mark - Setup

+ (void)setup {
    NSArray <id <QAToolkitTrigger>> *defaultTriggers = [self defaultTriggers];

    QAToolkit *toolkit = [QAToolkit sharedInstance];
    toolkit.dbToolkitSettings.widgetEnabled = YES;

    [self setupWithTriggers:defaultTriggers];
    //[self setupCrashReporting];
    [self showPerformanceWidget];
    
}

+ (void)setupNOWidget {
    NSArray <id <QAToolkitTrigger>> *defaultTriggers = [self defaultTriggers];
    [self setupWithTriggers:defaultTriggers];
    [self setupCrashReporting];
    [self forceNoWidget];
    //[self showPerformanceWidget];
}

+ (void)setupWithTriggers:(NSArray<id<QAToolkitTrigger>> *)triggers {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    //[toolkit setupSettings];
    NSMutableArray<id<QAToolkitTrigger>> * updatedTriggers = [[NSMutableArray alloc]init];
    if(!toolkit.dbToolkitSettings.longpressTriggerEnabled && !toolkit.dbToolkitSettings.shakeTriggerEnabled && !toolkit.dbToolkitSettings.tapTriggerEnabled){
        
        for (id <QAToolkitTrigger> trigger in triggers) {
            
            if([trigger isKindOfClass:[DBLongPressTrigger class]]){
                [toolkit.dbToolkitSettings updateLongpressTriggerEnabled:true];
                [updatedTriggers addObject:trigger];
                
            }
            if([trigger isKindOfClass:[DBShakeTrigger class]]){
                [toolkit.dbToolkitSettings updateShakeTriggerEnabled:true];
                
                [updatedTriggers addObject:trigger];
                
            }
            if([trigger isKindOfClass:[DBTapTrigger class]]){
                [toolkit.dbToolkitSettings updateTapTriggerEnabled:true];
                [updatedTriggers addObject:trigger];
                
            }
            
        }
    }
    else{
    
        
            if(toolkit.dbToolkitSettings.longpressTriggerEnabled){
                [updatedTriggers addObject:[DBLongPressTrigger triggerWithMinimumPressDuration:2]];
            }
        
        
            if(toolkit.dbToolkitSettings.shakeTriggerEnabled){
                [updatedTriggers addObject:[DBShakeTrigger trigger]];
            }
       
            if(toolkit.dbToolkitSettings.tapTriggerEnabled){
                [updatedTriggers addObject:[DBTapTrigger triggerWithNumberOfTapsRequired:2]];
            }
        
    
    }
    
    toolkit.triggers = [updatedTriggers copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(toolkit.dbToolkitSettings.widgetEnabled){
            toolkit.performanceToolkit.isWidgetShown=YES;
            [toolkit.dbToolkitSettings updateWidgetEnabled:YES];
        }
        else{
            toolkit.performanceToolkit.isWidgetShown=NO;
            [toolkit.dbToolkitSettings updateWidgetEnabled:NO];
        }
        
    });
    
    if(toolkit.dbToolkitSettings.crashLoggingEnabled){
        [toolkit.crashReportsToolkit setupCrashReporting];
    }

}



+ (NSArray <id <QAToolkitTrigger>> *)defaultTriggers {
    // return [NSArray arrayWithObject:[DBShakeTrigger trigger]];
    
    return [NSArray arrayWithObjects:[DBLongPressTrigger triggerWithMinimumPressDuration:2], nil];
}

+ (instancetype)sharedInstance {
    static QAToolkit *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QAToolkit alloc] init];
        //1.2.0
        [sharedInstance setupSettings];
        [sharedInstance registerForNotifications];
        [sharedInstance setupPerformanceToolkit];
        [sharedInstance setupConsoleOutputCaptor];
        [sharedInstance setupNetworkToolkit];
        [sharedInstance setupUserInterfaceToolkit];
        [sharedInstance setupLocationToolkit];
        [sharedInstance setupCoreDataToolkit];
        [sharedInstance setupCustomActions];
        [sharedInstance setupCustomVariables];
        [sharedInstance setupConfigurationPresets];
        [sharedInstance setupCrashReportsToolkit];
    });
    return sharedInstance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setting triggers

- (void)setTriggers:(NSArray<id<QAToolkitTrigger>> *)triggers {
    _triggers = [triggers copy];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self addTriggersToWindow:keyWindow];
    for (id <QAToolkitTrigger> trigger in triggers) {
        trigger.delegate = self;
    }
}

- (void)addTriggersToWindow:(UIWindow *)window {
    for (id <QAToolkitTrigger> trigger in self.triggers) {
        [trigger addToWindow:window];
    }
}

- (void)removeTriggersFromWindow:(UIWindow *)window {
    for (id <QAToolkitTrigger> trigger in self.triggers) {
        [trigger removeFromWindow:window];
    }
}


#pragma mark - Window notifications

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newKeyWindowNotification:)
                                                 name:UIWindowDidBecomeKeyNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidResignKeyNotification:)
                                                 name:UIWindowDidResignKeyNotification
                                               object:nil];
}



- (void)newKeyWindowNotification:(NSNotification *)notification {
    UIWindow *newKeyWindow = notification.object;
    [self addTriggersToWindow:newKeyWindow];
    [self.performanceToolkit updateKeyWindow:newKeyWindow];
}

- (void)windowDidResignKeyNotification:(NSNotification *)notification {
    UIWindow *windowResigningKey = notification.object;
    [self removeTriggersFromWindow:windowResigningKey];
    [self.performanceToolkit windowDidResignKey:windowResigningKey];
}

#pragma mark - Performance toolkit
+ (void)addWidgetToKeyWindow{
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    [toolkit addWidget];
    
}

- (void)addWidget{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self.performanceToolkit updateKeyWindow:keyWindow];
}

- (void)setupPerformanceToolkit {
    //QAToolkit *toolkit = [QAToolkit sharedInstance];
    if(self.dbToolkitSettings.performanceCaptureEnabled){
        self.performanceToolkit = [[DBPerformanceToolkit alloc] initWithWidgetDelegate:self];
    }
    //else [self.performanceToolkit stopPerformanceMeasurement];
}

- (void)stopPerformanceToolkit {
    [self.performanceToolkit stopPerformanceMeasurement];
    self.performanceToolkit = nil;
}


#pragma mark - Console output captor

- (void)setupConsoleOutputCaptor {
    self.consoleOutputCaptor = [DBConsoleOutputCaptor sharedInstance];
    self.consoleOutputCaptor.enabled = self.dbToolkitSettings.consoleLoggingEnabled;
}


+ (void)setCapturingConsoleOutputEnabled:(BOOL)enabled {
    if(enabled){
        QAToolkit *toolkit = [QAToolkit sharedInstance];
        toolkit.consoleOutputCaptor.enabled = enabled;
    }
}

//1.2.0
#pragma mark - Settings toolkit
- (void)setupSettings{
    self.dbToolkitSettings = [DBToolkitSettings sharedInstance];
    self.dbToolkitSettings.delegate = self;
}


#pragma mark - Network toolkit

- (void)setupNetworkToolkit {
    // QAToolkit *toolkit = [QAToolkit sharedInstance];
    self.networkToolkit = [DBNetworkToolkit sharedInstance];
    self.networkToolkit.loggingEnabled = self.dbToolkitSettings.networkLoggingEnabled;
}

+ (void)setNetworkRequestsLoggingEnabled:(BOOL)enabled {
    if(enabled){
        QAToolkit *toolkit = [QAToolkit sharedInstance];
        [toolkit.dbToolkitSettings updateNetworkLoggingEnabled:true];
    }
}

+ (void)shutdownNetworkRequestsLogging{
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    [toolkit.dbToolkitSettings updateNetworkLoggingEnabled:false];
    
}

#pragma mark - User interface toolkit

- (void)setupUserInterfaceToolkit {
    self.userInterfaceToolkit = [DBUserInterfaceToolkit sharedInstance];
    self.userInterfaceToolkit.colorizedViewBordersEnabled = NO;
    self.userInterfaceToolkit.slowAnimationsEnabled = NO;
    self.userInterfaceToolkit.showingTouchesEnabled = NO;
    [self.userInterfaceToolkit setupDebuggingInformationOverlay];
}

#pragma mark - Location toolkit

- (void)setupLocationToolkit {
    self.locationToolkit = [DBLocationToolkit sharedInstance];
}

#pragma mark - Core Data toolkit

- (void)setupCoreDataToolkit {
    self.coreDataToolkit = [DBCoreDataToolkit sharedInstance];
}

#pragma mark - Custom actions

- (void)setupCustomActions {
    _customActions = [NSMutableArray array];
}

+ (void)addCustomAction:(DBCustomAction *)customAction {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    [toolkit.customActions addObject:customAction];
}


+ (void)removeCustomActionWithName:(NSString *)customActionName {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    NSInteger idx = [toolkit.customActions indexOfObjectPassingTest:^BOOL(DBCustomAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:customActionName]) {
            *stop = YES;
            return TRUE;
        }
        
        return FALSE;
    }];
    
    if (idx != NSNotFound) {
        [toolkit.customActions removeObjectAtIndex:idx];
    }
}

+ (void)addCustomActions:(NSArray <DBCustomAction *> *)customActions {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    [toolkit.customActions addObjectsFromArray:customActions];
}

+ (NSDictionary*)getCustomActions{
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    NSMutableDictionary* mutableActions = [[NSMutableDictionary alloc] init];
    for (DBCustomAction *action in toolkit.customActions){
        [mutableActions setObject:action.body forKey:action.name];
    }
    NSDictionary* actions = [mutableActions copy];
    return actions;
}

#pragma mark - Custom variables

- (void)setupCustomVariables {
    _customVariables = [NSMutableDictionary dictionary];
}
//!
+ (void)addCustomVariable:(DBCustomVariable *)customVariable {
    [self removeCustomVariableWithName:customVariable.name];
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    toolkit.customVariables[customVariable.name] = customVariable;
}

+ (void)addCustomVariables:(NSArray <DBCustomVariable *> *)customVariables {
    for (DBCustomVariable *customVariable in customVariables) {
        [self addCustomVariable:customVariable];
    }
}

+ (void)removeCustomVariableWithName:(NSString *)variableName {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    DBCustomVariable *customVariable = toolkit.customVariables[variableName];
    [customVariable removeTarget:nil action:nil];
    toolkit.customVariables[variableName] = nil;
}

+ (void)removeCustomVariablesWithNames:(NSArray <NSString *> *)variableNames {
    for (NSString *variableName in variableNames) {
        [self removeCustomVariableWithName:variableName];
    }
}

+ (DBCustomVariable *)customVariableWithName:(NSString *)variableName {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    return toolkit.customVariables[variableName];
}
#pragma mark - Configuration presets toolkit

-(void) setupConfigurationPresets {
    self.configurationPresetToolkit = [[QATConfigurationPresetToolkit alloc] init];
}

+ (void) setConfigurationPresets:(NSArray<NSDictionary *>*) presets {
    assert([NSThread isMainThread]);
    
    presets = [[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:presets]] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [[evaluatedObject objectForKey:@"presetItems"] isKindOfClass:[NSArray class]] && [[evaluatedObject objectForKey:@"presetItems"] count] > 0;
    }]];
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    
    NSMutableArray<NSString *>* const savedSelected = [[[[toolkit.dbToolkitSettings.selectedPresets componentsSeparatedByString:@","] qatoolkit_mapObjectsUsingBlock:^id(NSString* obj, NSUInteger idx) {
        obj = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![[obj description] isKindOfClass:[NSString class]] || [obj isEqualToString:@""] || [obj integerValue] < 0) {
            return @""; // mark as invalid
        }
        return obj;
    }] qatoolkit_thru:^NSArray *(NSArray *obj) {
        
        NSMutableArray* const mutableCopy = [obj mutableCopy];
        
        while ([mutableCopy count] < [presets count]) {
            [mutableCopy addObject:@""];
        }
        
        while ([mutableCopy count] > [presets count]) {
            [mutableCopy removeLastObject];
        }
        
        return mutableCopy;
        
    }] mutableCopy];
    
    NSArray<NSString*>* const normalizedSelected = [presets qatoolkit_mapObjectsUsingBlock:^id(NSDictionary* preset, NSUInteger idx) {
        NSString* const saved = [savedSelected objectAtIndex:idx];
        NSString* const selected = [[preset objectForKey:@"selected"] description];
        if (![saved isEqualToString:@""]) {
            return saved;
        }
        if (![selected isKindOfClass:[NSString class]] || [selected isEqualToString:@""] || [selected integerValue] < 0) {
            return @"0";
        }
        return selected;
    }];
    
    NSArray<NSDictionary *>* const normalizedPresets = [[presets qatoolkit_mapObjectsUsingBlock:^id(NSDictionary* obj, NSUInteger idx) {
        NSMutableDictionary* const customEnv = [obj mutableCopy];
        [customEnv setObject:[normalizedSelected objectAtIndex:idx] forKey:@"selected"];
        return customEnv;
    }] copy];
    
    [toolkit.dbToolkitSettings updateSelectedPresets:[normalizedSelected componentsJoinedByString:@","]];
    [toolkit.configurationPresetToolkit setConfigurationPresets:normalizedPresets];
}

+ (void) sendConfigurationPresetsNotification{
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    [toolkit.configurationPresetToolkit sendUpdateNotification];
}

+ (id)currentConfigurationPresetValueForEnvironment:(NSString*)environment {
    
    environment = [environment uppercaseString];
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    
    NSArray<NSDictionary*>* const presets = [toolkit.configurationPresetToolkit presets];
    NSArray<NSIndexPath*>* const currentPresets = [toolkit.configurationPresetToolkit selectedItems];
    
    __block id result = nil;
    
    [presets enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger environmentIndex, BOOL * _Nonnull stop) {
        if ([[[obj objectForKey:@"preset"] uppercaseString] isEqualToString:environment]) {
            NSArray<NSDictionary*>* const values = [obj objectForKey:@"presetItems"];
            result = [[values objectAtIndex:[currentPresets objectAtIndex:environmentIndex].item] objectForKey:@"value"];
        }
        if (result) {
            *stop = YES;
        }
    }];
    
    return result;
}

static NSMutableArray* g_registeredSecurityApplicationGroupIdentifiers = nil;

+ (void)registerSecurityApplicationGroupIdentifier:(NSString*)identifier {
    if (!g_registeredSecurityApplicationGroupIdentifiers) {
        g_registeredSecurityApplicationGroupIdentifiers = [NSMutableArray new];
    }
    [g_registeredSecurityApplicationGroupIdentifiers addObject:identifier];
}

+ (NSArray<NSString*>*)registeredSecurityApplicationGroupIdentifiers {
    NSArray* obj = g_registeredSecurityApplicationGroupIdentifiers ? [g_registeredSecurityApplicationGroupIdentifiers copy] : @[];
    return [[[NSSet setWithArray:obj] allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark -
#pragma mark - Crash reports toolkit

- (void)setupCrashReportsToolkit {
    self.crashReportsToolkit = [DBCrashReportsToolkit sharedInstance];
    self.crashReportsToolkit.consoleOutputCaptor = self.consoleOutputCaptor;
    self.crashReportsToolkit.buildInfoProvider = [DBBuildInfoProvider new];
    self.crashReportsToolkit.deviceInfoProvider = [DBDeviceInfoProvider new];
}

+ (void)setupCrashReporting {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if(toolkit.dbToolkitSettings.crashLoggingEnabled){
        [toolkit.crashReportsToolkit setupCrashReporting];
    }
}

- (void)stopCrashReporting{
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    [toolkit.crashReportsToolkit disableCrashReporting];
}


#pragma mark - Resources

+ (void)clearKeychain {
    DBKeychainToolkit *keychainToolkit = [DBKeychainToolkit new];
    if ([keychainToolkit respondsToSelector:@selector(handleClearAction)]) {
        [keychainToolkit handleClearAction];
    }
}

+ (void)clearUserDefaults {
    DBUserDefaultsToolkit *userDefaultsToolkit = [DBUserDefaultsToolkit new];
    if ([userDefaultsToolkit respondsToSelector:@selector(handleClearAction)]) {
        [userDefaultsToolkit handleClearAction];
    }
}

#pragma mark - Convenience methods

+ (void)showMenu {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if (!toolkit.showsMenu) {
        [toolkit showMenu];
    }
}

+ (void)hideMenu {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if (toolkit.showsMenu) {
        [toolkit hideMenu];
    }
}

+ (void)showPerformanceWidget {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if(toolkit.dbToolkitSettings.widgetEnabled){
        DBPerformanceToolkit *performanceToolkit = toolkit.performanceToolkit;
        performanceToolkit.isWidgetShown = YES;
        [toolkit.dbToolkitSettings updateWidgetEnabled:YES];
    }
    else{
        DBPerformanceToolkit *performanceToolkit = toolkit.performanceToolkit;
        performanceToolkit.isWidgetShown = NO;
        [toolkit.dbToolkitSettings updateWidgetEnabled:NO];
    }
}

+ (void)forceNoWidget {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    
    DBPerformanceToolkit *performanceToolkit = toolkit.performanceToolkit;
    performanceToolkit.isWidgetShown = NO;
    [toolkit.dbToolkitSettings updateWidgetEnabled:NO];
    
}

+ (void)forceShowWidget {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    
    DBPerformanceToolkit *performanceToolkit = toolkit.performanceToolkit;
    performanceToolkit.isWidgetShown = YES;
    [toolkit.dbToolkitSettings updateWidgetEnabled:YES];
}

+ (void)showDebuggingInformationOverlay {
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    DBUserInterfaceToolkit *userInterfaceToolkit = toolkit.userInterfaceToolkit;
    if (userInterfaceToolkit.isDebuggingInformationOverlayAvailable) {
        [userInterfaceToolkit showDebuggingInformationOverlay];
    }
}

#pragma mark - Showing menu

- (void)showMenu {
    self.showsMenu = YES;
    UIViewController *presentingViewController = [self topmostViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.menuViewController];

    if (@available(iOS 13, *)) {
        navigationController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    navigationController.modalPresentationCapturesStatusBarAppearance = YES;
    [presentingViewController presentViewController:navigationController animated:YES completion:^{
        // We need this to properly handle a case of menu being dismissed because of dismissing of the view controller that presents it.
        [navigationController.presentationController addObserver:self
                                                      forKeyPath:QAToolkitObserverPresentationControllerPropertyKeyPath
                                                         options:0
                                                         context:nil];
    }];
}

-(void) hideMenu {
    UIViewController *presentingViewController = self.menuViewController.navigationController.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES completion:^{
        self.showsMenu = NO;
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[UIPresentationController class]]) {
        UIPresentationController *presentationController = (UIPresentationController *)object;
        if (presentationController.containerView == nil) {
            // The menu was dismissed.
            self.showsMenu = NO;
            [presentationController removeObserver:self forKeyPath:QAToolkitObserverPresentationControllerPropertyKeyPath];
        }
    }
}

- (DBMenuTableViewController *)menuViewController {
    if (!_menuViewController) {
        NSBundle *bundle = [NSBundle debugToolkitBundle];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBMenuTableViewController" bundle:bundle];
        _menuViewController = [storyboard instantiateInitialViewController];
        _menuViewController.performanceToolkit = self.performanceToolkit;
        _menuViewController.consoleOutputCaptor = self.consoleOutputCaptor;
        _menuViewController.networkToolkit = self.networkToolkit;
        _menuViewController.userInterfaceToolkit = self.userInterfaceToolkit;
        _menuViewController.locationToolkit = self.locationToolkit;
        _menuViewController.coreDataToolkit = self.coreDataToolkit;
        _menuViewController.crashReportsToolkit = self.crashReportsToolkit;
        _menuViewController.configurationPresetToolkit = self.configurationPresetToolkit;
        _menuViewController.buildInfoProvider = [DBBuildInfoProvider new];
        _menuViewController.deviceInfoProvider = [DBDeviceInfoProvider new];
        _menuViewController.delegate = self;
    }
    _menuViewController.customVariables = self.customVariables.allValues;
    _menuViewController.customActions = self.customActions;
    return _menuViewController;
}

- (UIViewController *)topmostViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self topmostViewControllerWithRootViewController:rootViewController];
}

- (UIViewController *)topmostViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topmostViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        if (navigationController.visibleViewController == nil) {
            return navigationController;
        }
        return [self topmostViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topmostViewControllerWithRootViewController:presentedViewController];
    }
    return rootViewController;
}

//1.2.0
#pragma mark - QAToolkitTriggerDelegate

- (void)debugToolkitTriggered:(id<QAToolkitTrigger>)trigger {
    if (!self.showsMenu) {
        [self showMenu];
    }
}

#pragma mark - DBToolkitSettingsDelegate
- (void)dbToolkitSettingsWidgetChange:(BOOL) flag{
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if( toolkit.dbToolkitSettings.widgetEnabled){
        [toolkit addWidget];
        toolkit.performanceToolkit.isWidgetShown =YES;
    }
    if( !toolkit.dbToolkitSettings.widgetEnabled){
        toolkit.performanceToolkit.isWidgetShown = NO;
    }
    
}

- (void)dbToolkitSettingsNetworkLoggingChange:(BOOL)flag{
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if(toolkit.dbToolkitSettings.networkLoggingEnabled){
        //[toolkit setupNetworkToolkit];
        toolkit.networkToolkit.loggingEnabled = toolkit.dbToolkitSettings.networkLoggingEnabled;
    }
    if(!toolkit.dbToolkitSettings.networkLoggingEnabled){
        toolkit.networkToolkit.loggingEnabled = toolkit.dbToolkitSettings.networkLoggingEnabled;
        //toolkit.networkToolkit = nil;
    }
}

- (void)dbToolkitSettingsCrashLoggingChange:(BOOL)flag{
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if(toolkit.dbToolkitSettings.crashLoggingEnabled){
        [toolkit setupCrashReportsToolkit];
    }
    if(!toolkit.dbToolkitSettings.crashLoggingEnabled){
        [toolkit.crashReportsToolkit disableCrashReporting];
        toolkit.crashReportsToolkit = nil;
    }
}

- (void)dbToolkitSettingsConsoleLoggingChange:(BOOL)flag{
    
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    if(toolkit.dbToolkitSettings.consoleLoggingEnabled){
        
    }
    if(!toolkit.dbToolkitSettings.consoleLoggingEnabled){
        
        [toolkit.consoleOutputCaptor setEnabled:NO];
    }
}

- (void)dbToolkitSettingsPerformanceCaptureChange:(BOOL)flag{
    QAToolkit *toolkit = [QAToolkit sharedInstance];
    
    if(toolkit.dbToolkitSettings.performanceCaptureEnabled){
        [toolkit setupPerformanceToolkit];
    }
    if(!toolkit.dbToolkitSettings.performanceCaptureEnabled){
        toolkit.performanceToolkit.isWidgetShown = NO;
        [toolkit stopPerformanceToolkit];
        toolkit.performanceToolkit = nil;
    }
}
//Triggers
- (void)dbToolkitSettingsLongpressTriggerChange:(BOOL)flag{
    
    
}

- (void)dbToolkitSettingsShakeTriggerChange:(BOOL)flag{
    
    
}

- (void)dbToolkitSettingsTapTriggerChange:(BOOL)flag{
    
    
}


#pragma mark - DBMenuTableViewControllerDelegate

- (void)menuTableViewControllerDidTapClose:(DBMenuTableViewController *)menuTableViewController {
    UIViewController *presentingViewController = self.menuViewController.navigationController.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES completion:^{
        self.showsMenu = NO;
    }];
}

#pragma mark - DBPerformanceWidgetViewDelegate

- (void)performanceWidgetView:(DBPerformanceWidgetView *)performanceWidgetView didTapOnSection:(DBPerformanceSection)section {
    //BOOL shouldAnimateShowingPerformance = YES;
    if (!self.showsMenu) {
        [self showMenu];
        //shouldAnimateShowingPerformance = NO;
    }
    /*
     UINavigationController *navigationController = self.menuViewController.navigationController;
     if (navigationController.viewControllers.count > 1 && [navigationController.viewControllers[1] isKindOfClass:[DBPerformanceTableViewController class]]) {
     // Only update the presented DBPerformanceTableViewController instance.
     DBPerformanceTableViewController *performanceTableViewController = (DBPerformanceTableViewController *)navigationController.viewControllers[1];
     performanceTableViewController.selectedSection = section;
     } else {
     // Update navigation controller's view controllers.
     [self.menuViewController openPerformanceMenuWithSection:section
     animated:shouldAnimateShowingPerformance];
     }
     */
}



@end
