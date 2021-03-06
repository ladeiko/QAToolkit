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

#import "DBBuildInfoProvider.h"

@implementation DBBuildInfoProvider

- (NSString *)applicationName {
    return [self infoDictionaryObjectForKey:(NSString *)kCFBundleNameKey];
}

- (NSString *)buildVersion {
    return [self infoDictionaryObjectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildNumber {
    return [self infoDictionaryObjectForKey:@"CFBundleVersion"];
}

- (NSString *)buildInfoString {
    NSString *buildInfoStringFormat = @"%@, v.%@ (%@) + %@";
    return [NSString stringWithFormat:buildInfoStringFormat, [self applicationName], [self buildVersion], [self buildNumber] , [self frameworkNumber]];
}

-(NSString *) applicationNameVer{
    NSString *buildInfoStringFormat =@"%@%@";
    return [NSString stringWithFormat:buildInfoStringFormat,[self applicationName],[self buildVersion]];
}


//1.2.0
- (NSString *)frameworkNumber{
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [DBBuildInfoProvider class]] infoDictionary];
    
    NSString *name = @"QAT";
    NSString *version = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
    NSString *buildInfoStringFormat = @"%@ v.%@";
    return [NSString stringWithFormat:buildInfoStringFormat, name, version];
}


#pragma mark - Private methods

- (NSString *)infoDictionaryObjectForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:key];
}

@end
