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

#import "DBNetworkToolkit.h"
#import "DBURLProtocol.h"
#import "DBRequestModel.h"

@interface DBNetworkToolkit () <DBRequestModelDelegate>

@property (nonatomic, strong, readonly) NSMutableArray<DBRequestModel*> *requests;
@property (nonatomic, strong) NSMapTable *runningRequestsModels;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation DBNetworkToolkit {
    BOOL _loggingEnabledSafe;
}

- (void)runOnMain:(void(^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), [block copy]);
    }
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupOperationQueue];
        [self resetLoggedData];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static DBNetworkToolkit *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBNetworkToolkit alloc] init];
        [self setupURLProtocol];
    });
    return sharedInstance;
}

+ (void)setupURLProtocol {
    [NSURLProtocol registerClass:[DBURLProtocol class]];
}

- (void)setupOperationQueue {
    self.operationQueue = [NSOperationQueue new];
    self.operationQueue.maxConcurrentOperationCount = 1;
}

- (void)resetLoggedData {
    _requests = [NSMutableArray array];
    _runningRequestsModels = [NSMapTable strongToWeakObjectsMapTable];
    [self removeOldSavedRequests];
}

- (void)removeOldSavedRequests {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = [self savedRequestsPath];
    NSError *error = nil;
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

- (NSString *)savedRequestsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"DBDebugToolkit/Network"];
}

#pragma mark - Logging settings 

- (void)setLoggingEnabled:(BOOL)loggingEnabled {

    if (_loggingEnabled == loggingEnabled) {
        return;
    }

    _loggingEnabled = loggingEnabled;

    [self.operationQueue addOperationWithBlock:^{

        self->_loggingEnabledSafe = loggingEnabled;

        if (!self->_loggingEnabledSafe) {
            [self resetLoggedData];
            [self.delegate networkDebugToolkitDidUpdateRequestsList:self];
        }
    }];

    [self runOnMain: ^{
        [self.delegate networkDebugToolkit:self didSetEnabled:self->_loggingEnabled];
    }];
}

#pragma mark - Saving request data

- (void)saveRequest:(NSURLRequest *)request {
    [self.operationQueue addOperationWithBlock:^{

        if (!self->_loggingEnabledSafe) {
            return;
        }

        DBRequestModel *requestModel = [DBRequestModel requestModelWithRequest:request];
        requestModel.delegate = self;
        [self.runningRequestsModels setObject:requestModel forKey:request.description];
        [self.requests addObject:requestModel];
        [self.delegate networkDebugToolkitDidUpdateRequestsList:self];
    }];
}

- (void)saveRequestOutcome:(DBRequestOutcome *)requestOutcome forRequest:(NSURLRequest *)request {
    [self.operationQueue addOperationWithBlock:^{

        DBRequestModel* const requestModel = [self.runningRequestsModels objectForKey:request.description];
        if (requestModel && self->_loggingEnabledSafe) {
            [requestModel saveOutcome:requestOutcome];
            [requestModel saveBodyWithData:request.HTTPBody inputStream:request.HTTPBodyStream];
        }

        [self.runningRequestsModels removeObjectForKey:request.description];

        if (requestModel && self->_loggingEnabledSafe) {
            [self.delegate networkDebugToolkit:self didUpdateRequest:requestModel];
        }
    }];
}

- (void)requestsOnQueue:(NSOperationQueue*)queue completion:(void(^)(NSArray<DBRequestModel*>* requests))completion {
    [self.operationQueue addOperationWithBlock:^{
        NSArray* requests = [self.requests copy];
        [queue addOperationWithBlock:^{
            completion(requests);
        }];
    }];
}

#pragma mark - DBRequestModelDelegate

- (void)requestModelDidFinishSynchronization:(DBRequestModel *)requestModel {
    [self.operationQueue addOperationWithBlock:^{
        [self.delegate networkDebugToolkit:self didUpdateRequest:requestModel];
    }];
}

@end
