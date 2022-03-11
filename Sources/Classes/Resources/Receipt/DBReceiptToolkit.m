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

#import "DBReceiptToolkit.h"
#import "QAToolkitReceipt.h"
#import <objc/message.h>
#import <TopViewControllerDetection/TopViewControllerDetection-Swift.h>

@interface DBReceiptToolkit () {
    NSString* _searchString;
    NSInteger _sortScope;
}

@property (nonatomic, strong, readonly) NSMutableArray<NSDictionary<NSString*, NSString*>*> *keys;
@property (nonatomic, weak) id<DBTitleValueListViewModelController> controller;
@end

@implementation DBReceiptToolkit

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reload];
    }
    
    return self;
}

- (void)reload {

    _keys = [NSMutableArray array];

    //NSArray* f (id, SEL) = (NSArray*(id,SEL))objc_msgSend;

    NSArray<NSDictionary*>* const info =((NSArray* (*)(id, SEL))objc_msgSend)(NSClassFromString(@"QAToolkitReceiptBridge"), NSSelectorFromString(@"info"));

    if(!info){
        [self.keys addObject:@{@"title": @"NO LOCAL RECEIPT FOUND"}];
        return;
    }

    NSArray* sorted = [[info filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {

        if ([self.searchString length] == 0) {
            return YES;
        }

        if (![evaluatedObject objectForKey:@"searchable"]) {
            return YES;
        }

        NSArray<NSString*>* searchable = [evaluatedObject objectForKey:@"searchable"];
        return [[searchable filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject rangeOfString:self.searchString].location != NSNotFound;
        }]] count] > 0;
    }]] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

        NSString* const _id1 = [obj1 objectForKey:@"id"];
        NSString* const _id2 = [obj2 objectForKey:@"id"];

        if (!_id1) {
            return NSOrderedAscending;
        }

        if (!_id2) {
            return NSOrderedDescending;
        }

        NSString* const _date1 = [obj1 objectForKey:@"date"];
        NSString* const _date2 = [obj2 objectForKey:@"date"];

        if (_sortScope == 1) {
            return [_date1 caseInsensitiveCompare:_date2];
        }
        else {
            return -[_date1 caseInsensitiveCompare:_date2];
        }
    }];

    [self.keys addObjectsFromArray:sorted];
}

#pragma mark - DBTitleValueListViewModel

- (NSString *)viewTitle {
    return @"Receipt Data";
}

- (NSInteger)numberOfItems {
    return self.keys.count;
}

- (DBTitleValueTableViewCellDataSource *)dataSourceForItemAtIndex:(NSInteger)index {
    NSDictionary<NSString*, NSString*>* const item = self.keys[index];
    NSString* const title = item[@"title"];
    NSString* const value = item[@"value"];
    return [DBTitleValueTableViewCellDataSource dataSourceWithTitle:title value:(value ? value : @"")];
}

- (NSString *)emptyListDescriptionString {
    return @"There are no entries in the receipt.";
}

- (NSArray<NSString*>*)sortScopes {
    return @[
        @"Date ↑",
        @"Date ↓",
    ];
}

- (NSString*)searchString {
    return _searchString;
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = [searchString copy];
    [self reload];
}

- (NSInteger)sortScope {
    return _sortScope;
}

- (void)setSortScope:(NSInteger)sortScope {
    _sortScope = sortScope;
    [self reload];
    [self.controller reloadTable];
}

- (NSArray*)customActions {
    return @[
        @{
            @"title": @"Refresh",
            @"action": [^{

                UIWindow* const window = [[UIApplication sharedApplication] keyWindow];
                UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                activity.color = [UIColor blueColor];
                UIView* dimView = [[UIView alloc] initWithFrame:window.bounds];
                dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
                dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                [window addSubview:dimView];
                [dimView addSubview:activity];

                activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
                activity.center = CGPointMake(dimView.bounds.size.width / 2, dimView.bounds.size.height / 2);

                [activity startAnimating];

                [UIView animateWithDuration:0.35 animations:^{
                    [dimView setAlpha:1];
                } completion:^(BOOL finished) {

                }];

                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

                ((void (*)(id, SEL, id))objc_msgSend)(NSClassFromString(@"QAToolkitReceiptBridge"), NSSelectorFromString(@"refreshWithCompletion:"), ^(NSError* error){

                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                    [UIView animateWithDuration:0.35 animations:^{
                        [dimView setAlpha:0];

                    } completion:^(BOOL finished) {
                        [dimView removeFromSuperview];

                        if (error) {
                            if (!([[error domain] isEqualToString:@"SSErrorDomain"] && [error code] == 16)) {
                                UIAlertController* const alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                [[[UIApplication sharedApplication] findTopViewController] presentViewController:alert animated:true completion:nil];
                            }
                        }
                        else {
                            [self reload];
                            [self.controller reloadTable];
                        }

                    }];
                });

            } copy]
        }
    ];
}

@end
