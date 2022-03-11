//
//  NSEntityDescription+Attributes.m
//  QAToolkit
//
//  Created by Siarhei Ladzeika on 21.12.2020.
//
//

#import "NSEntityDescription+Attributes.h"

@implementation NSEntityDescription(Attributes)

- (NSArray<NSString *> *)namesOfPersistentAttributes {
    NSMutableArray<NSString *> *names = [NSMutableArray new];

    [self.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSAttributeDescription * _Nonnull obj, BOOL * _Nonnull stop) {
        if (!obj.isTransient) {
            [names addObject:key];
        }
    }];

    return names;
}

@end
