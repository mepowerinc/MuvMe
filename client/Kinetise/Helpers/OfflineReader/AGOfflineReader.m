#import "AGOfflineReader.h"
#import "AGOfflineReaderFeedOperation.h"
#import "AGOfflineReaderImageOperation.h"

@interface AGOfflineReader () <AGOfflineReaderOperationDelegate>{
    NSOperationQueue *queue;
    NSArray *json;
    NSInteger progressCount;
    NSInteger count;
    NSError *completionError;
    BOOL isProcessing;
    NSInteger filesCount;
    NSInteger redundantFilesCount;
}
@property(nonatomic, retain) NSArray *json;
@property(nonatomic, retain) NSError *completionError;
@end

@implementation AGOfflineReader

@synthesize json;
@synthesize completionBlock;
@synthesize progressBlock;
@synthesize completionError;

- (void)dealloc {
    self.completionBlock = nil;
    self.progressBlock = nil;
    self.json = nil;
    self.completionError = nil;
    [queue cancelAllOperations];
    [queue release];
    [super dealloc];
}

- (id)initWithJSON:(NSArray *)json_ {
    self = [super init];

    // json
    self.json = json_;

    // queue
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;

    return self;
}

- (void)start {
    if (isProcessing) {
        [self stop];
    }
    [self retain];
    isProcessing = YES;
    progressCount = NSNotFound;
    count = 0;
    filesCount = 0;
    redundantFilesCount = 0;
    self.completionError = nil;

    // tasks
    queue.suspended = YES;
    for (NSDictionary *dict in json) {
        AGOfflineReaderOperation *newOperation = [AGOfflineReaderOperation operationWithJSON:dict];

        if (![queue.operations containsObject:newOperation]) {
            newOperation.delegate = self;
            [queue addOperation:newOperation];
            ++count;
            ++filesCount;
        } else {
            ++redundantFilesCount;
        }
    }
    queue.suspended = NO;

    // no tasks
    if (queue.operationCount == 0) {
        completionBlock(self, nil);
        [self stop];
    }
}

- (void)stop {
    isProcessing = NO;
    [queue cancelAllOperations];
    [self release];
}

#pragma mark - AGOfflineReaderOperationDelegate

- (void)offlineReaderOperation:(AGOfflineReaderOperation *)operation didEndWithOperations:(NSArray *)array andError:(NSError *)error {
    // completion error
    if (error) {
        self.completionError = error;
    }

    // count
    --count;

    // operations
    queue.suspended = YES;
    for (NSDictionary *dict in array) {
        AGOfflineReaderOperation *newOperation = [AGOfflineReaderOperation operationWithJSON:dict];

        if (![queue.operations containsObject:newOperation]) {
            newOperation.delegate = self;
            [queue addOperation:newOperation];
            ++count;
            ++filesCount;
        } else {
            ++redundantFilesCount;
        }
    }
    queue.suspended = NO;

    // progress
    BOOL onlyImages = YES;

    for (NSOperation *operation in queue.operations) {
        if ([operation isKindOfClass:[AGOfflineReaderFeedOperation class]]) {
            onlyImages = NO;
        }
    }

    if (onlyImages && queue.operationCount > 0) {
        if (progressCount == NSNotFound) {
            progressCount = queue.operationCount;
        }
        float progress = 1.0f-((float)queue.operationCount-1)/(float)progressCount;

        // progress block
        if (progressBlock) {
            progressBlock(self, progress);
        }
    }

    // completion block
    if (count == 0) {
        NSLog(@"[Offline reading] Total files: %zd, redundant: %zd", filesCount, redundantFilesCount);
        completionBlock(self, completionError);
        [self stop];
    }
}

@end
