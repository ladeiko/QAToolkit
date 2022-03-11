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

#import "DBUserDefaultsToolkit.h"
#import "QAToolkitUserDefaultsKeys.h"

@interface DBUserDefaultsToolkit ()

@property (nonatomic, strong, readonly) NSMutableArray *keys;

@end

@implementation DBUserDefaultsToolkit

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupKeys];
    }
    
    return self;
}

- (void)setupKeys {
    _keys = [NSMutableArray array];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [self.keys addObjectsFromArray:[[[NSUserDefaults standardUserDefaults] persistentDomainForName:appDomain] allKeys]];
    [self.keys removeObject:QAToolkitUserDefaultsSimulatedLocationLatitudeKey];
    [self.keys removeObject:QAToolkitUserDefaultsSimulatedLocationLongitudeKey];
    [self.keys sortUsingSelector:@selector(compare:)];
}

- (void)setKeysToIgnore:(NSArray<NSString *> *)keysToIgnore {
    _keysToIgnore = [keysToIgnore copy];
    if (self.keysToIgnore) {
        [self.keys removeObjectsInArray:self.keysToIgnore];
    }
}

#pragma mark - DBTitleValueListViewModel

- (NSString *)viewTitle {
    return @"User defaults";
}

- (NSInteger)numberOfItems {
    return self.keys.count;
}

- (DBTitleValueTableViewCellDataSource *)dataSourceForItemAtIndex:(NSInteger)index {
    NSString *key = self.keys[index];
    NSString *value = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:key]];
    return [DBTitleValueTableViewCellDataSource dataSourceWithTitle:key
                                                              value:value];
}

- (void)handleClearAction {
    for (NSString *key in self.keys) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.keys removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QATUserDefaultsClearedNotification" object:self userInfo:nil];
}

- (void)handleDeleteItemActionAtIndex:(NSInteger)index {
    NSString *key = self.keys[index];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              key,@"item id",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QATUserDefaultsDeletedItemNotification" object:self userInfo:userInfo];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.keys removeObject:key];
    
}

- (NSString *)emptyListDescriptionString {
    return @"There are no entries in the user defaults.";
}

@end
