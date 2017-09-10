#import "AGAssetsManager.h"

@interface AGAssetTaskDelegate : NSObject

@property(nonatomic, retain) NSMutableData *data;
@property(nonatomic, assign) id<NSURLSessionDataDelegate> delegate;
@property(nonatomic, copy) void (^completionBlock)(NSData *data, NSHTTPURLResponse *response, NSError *error);

@end

@implementation AGAssetTaskDelegate

@synthesize data;
@synthesize delegate;
@synthesize completionBlock;

- (void)dealloc {
    self.data = nil;
    self.delegate = nil;
    self.completionBlock = nil;
    [super dealloc];
}

@end

@interface AGAssetsManager () <NSURLSessionDataDelegate>{
    NSOperationQueue *feedProcessingQueue;
    NSOperationQueue *imageProcessingQueue;
    NSArray<NSURLSession *> *sessions;
    NSArray<NSMutableDictionary *> *tasksDelegates;
}
@property(nonatomic, retain) NSOperationQueue *feedProcessingQueue;
@property(nonatomic, retain) NSOperationQueue *imageProcessingQueue;
@property(nonatomic, retain) NSArray<NSURLSession *> *sessions;
@property(nonatomic, retain) NSArray<NSMutableDictionary *> *tasksDelegates;
@end

@implementation AGAssetsManager

@synthesize feedProcessingQueue;
@synthesize imageProcessingQueue;
@synthesize sessions;
@synthesize tasksDelegates;

SINGLETON_IMPLEMENTATION(AGAssetsManager)

#pragma mark - Initialization

- (void)dealloc {
    self.feedProcessingQueue = nil;
    self.imageProcessingQueue = nil;
    self.sessions = nil;
    self.tasksDelegates = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;

    // sessions
    self.sessions = @[
        [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]],
        [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]],
        [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]],
        [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]]
    ];

    // tasks delegates
    self.tasksDelegates = @[
        [NSMutableDictionary dictionary],
        [NSMutableDictionary dictionary],
        [NSMutableDictionary dictionary],
        [NSMutableDictionary dictionary]
    ];

    // feed processing queue
    self.feedProcessingQueue = [[[NSOperationQueue alloc] init] autorelease];
    feedProcessingQueue.maxConcurrentOperationCount = 1;

    // image processing queue
    self.imageProcessingQueue = [[[NSOperationQueue alloc] init] autorelease];
    imageProcessingQueue.maxConcurrentOperationCount = 1;

    return self;
}

#pragma mark - Lifecycle

- (NSURLSessionDataTask *)dataTask:(AGAssetDataType)type silent:(BOOL)silent request:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate completion:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))completionBlock {
    NSInteger index = 2*type+(silent ? 1 : 0);

    NSURLSessionDataTask *task = [sessions[index] dataTaskWithRequest:request];

    AGAssetTaskDelegate *taskDelegate = [[AGAssetTaskDelegate alloc] init];
    tasksDelegates[index][@(task.taskIdentifier)] = taskDelegate;
    taskDelegate.delegate = delegate;
    taskDelegate.completionBlock = completionBlock;
    [taskDelegate release];

    return task;
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    completionHandler(request);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSInteger index = [sessions indexOfObject:session];
    AGAssetTaskDelegate *taskDelegate = tasksDelegates[index][@(dataTask.taskIdentifier)];

    taskDelegate.data = [NSMutableData data];

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSInteger index = [sessions indexOfObject:session];
    AGAssetTaskDelegate *taskDelegate = tasksDelegates[index][@(dataTask.taskIdentifier)];

    [taskDelegate.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSInteger index = [sessions indexOfObject:session];
    AGAssetTaskDelegate *taskDelegate = tasksDelegates[index][@(task.taskIdentifier)];

    if (taskDelegate.completionBlock) {
        taskDelegate.completionBlock(taskDelegate.data, (NSHTTPURLResponse *)task.response, error);
    }

    tasksDelegates[index][@(task.taskIdentifier)] = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    NSInteger index = [sessions indexOfObject:session];
    AGAssetTaskDelegate *taskDelegate = tasksDelegates[index][@(dataTask.taskIdentifier)];

    __block NSCachedURLResponse *response = proposedResponse;

    /*
       NSHTTPURLResponse* HTTPResponse = (NSHTTPURLResponse*)proposedResponse.response;
       NSDictionary* headers = HTTPResponse.allHeaderFields;

       if( !headers[@"Cache-Control"] ){
        NSMutableDictionary* modifiedHeaders = [headers.mutableCopy autorelease];
        modifiedHeaders[@"Cache-Control"] = @"max-age=1";

        NSHTTPURLResponse* modifiedHTTPResponse = [[[NSHTTPURLResponse alloc]
                                                    initWithURL:HTTPResponse.URL
                                                    statusCode:HTTPResponse.statusCode
                                                    HTTPVersion:@"HTTP/1.1"
                                                    headerFields:modifiedHeaders] autorelease];

        proposedResponse = [[[NSCachedURLResponse alloc] initWithResponse:modifiedHTTPResponse
                                                                     data:proposedResponse.data
                                                                 userInfo:proposedResponse.userInfo
                                                            storagePolicy:NSURLCacheStorageAllowed] autorelease];
       }*/

    if ([taskDelegate.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)]) {
        [taskDelegate.delegate URLSession:session dataTask:dataTask willCacheResponse:response completionHandler:^(NSCachedURLResponse *cachedResponse){
            response = cachedResponse;
        }];
    }

    completionHandler(response);
}

@end
