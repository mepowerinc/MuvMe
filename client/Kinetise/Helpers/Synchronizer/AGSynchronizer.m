#import "AGSynchronizer.h"
#import "AGApplication.h"
#import "AGReachability.h"
#import "AGServicesManager.h"
#import "AGAlterApiResponse.h"
#import <JSONQuery/NSData+JQ.h>
#import "NSObject+Nil.h"
#import "NSString+URL.h"
#import "NSString+UriEncoding.h"
#import "NSURLRequest+HTTP.h"
#import "GDataXMLNode+XPath.h"
#import "NSString+GUID.h"

#define KEY_SYNCHRONIZER_REQUESTS @"synchronizer_requests"
#define KEY_SYNCHRONIZER_SYNCHRONIZED_REQUESTS @"synchronizer_synchronized_requests"

@interface AGSynchronizer () <NSURLSessionDelegate, NSURLSessionTaskDelegate>{
    NSURLSession *session;
    AGSynchronizerRequest *currentRequest;
    NSOperationQueue *operationQueue;
    NSMutableArray *requests;
    NSMutableArray *synchronizedRequests;
}
@end

@implementation AGSynchronizer

SINGLETON_IMPLEMENTATION(AGSynchronizer)

#pragma mark - Initialization

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [session release];
    [operationQueue release];
    [requests release];
    [synchronizedRequests release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // cache folder
    if ([[NSFileManager defaultManager] fileExistsAtPath:FILE_PATH_CACHE(@"Synchronizer")]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:FILE_PATH_CACHE(@"Synchronizer") withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;

    // session
    session = [[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]] retain];

    // requests
    requests = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SYNCHRONIZER_REQUESTS] ] retain];
    synchronizedRequests = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SYNCHRONIZER_SYNCHRONIZED_REQUESTS] ] retain];

    if (!requests) requests = [[NSMutableArray alloc] init];
    if (!synchronizedRequests) synchronizedRequests = [[NSMutableArray alloc] init];

    // operation queue
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;

    // notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNetworkStatus:) name:kReachabilityChangedNotification object:nil];

    // next request
    [self nextRequest];

    return self;
}

#pragma mark - Lifecycle

- (id)getRequestValue:(NSString *)key {
    id value = nil;

    for (AGSynchronizerRequest *request in synchronizedRequests) {
        if ([request.key isEqualToString:key]) {
            value = request.value;
        }
    }

    for (AGSynchronizerRequest *request in requests) {
        if ([request.key isEqualToString:key]) {
            value = request.value;
        }
    }

    return value;
}

- (NSDate *)getRequestTimestamp:(NSString *)key {
    NSDate *timestamp = [NSDate distantFuture];

    for (AGSynchronizerRequest *request in synchronizedRequests) {
        if ([request.key isEqualToString:key]) {
            timestamp = request.sendTimestamp;
        }
    }

    for (AGSynchronizerRequest *request in requests) {
        if ([request.key isEqualToString:key]) {
            timestamp = request.sendTimestamp;
        }
    }

    return timestamp;
}

- (void)removeRequest:(NSString *)key {
    for (int i = 0; i < synchronizedRequests.count; ++i) {
        AGSynchronizerRequest *request = synchronizedRequests[i];
        if (request != currentRequest) {
            if ([request.key isEqualToString:key]) {
                [synchronizedRequests removeObjectAtIndex:i];
                --i;
            }
        }
    }

    [self saveData];
}

- (void)addRequest:(AGSynchronizerRequest *)newRequest {
    NSInteger index = NSNotFound;

    // request key
    if (newRequest.key) {
        for (int i = 0; i < requests.count; ++i) {
            AGSynchronizerRequest *request = requests[i];
            if (request != currentRequest) {
                if ([newRequest isEqual:request]) {
                    index = i;
                }
            }
        }
    } else {
        newRequest.key = [NSString stringWithGUID];
    }

    // body
    if (newRequest.httpBody.length > 1024) {
        NSString *filePath = [NSString stringWithFormat:@"Synchronizer/%@", newRequest.key];
        newRequest = [[newRequest copy] autorelease];
        newRequest.httpBodyFilePath = FILE_PATH_CACHE(filePath);
        [newRequest.httpBody writeToFile:newRequest.httpBodyFilePath atomically:YES];
        newRequest.httpBody = nil;
    }

    // add request
    if (index == NSNotFound) {
        [requests addObject:newRequest];
    } else {
        [requests replaceObjectAtIndex:index withObject:newRequest];
    }
    [self saveData];

    // next request
    [self nextRequest];
}

- (void)saveData {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:requests] forKey:KEY_SYNCHRONIZER_REQUESTS];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:synchronizedRequests] forKey:KEY_SYNCHRONIZER_SYNCHRONIZED_REQUESTS];
}

- (void)nextRequest {
    if (requests.count == 0 || currentRequest || [AGReachability sharedInstance].reachability.currentReachabilityStatus == NotReachable) return;

    // request
    currentRequest = [requests firstObject];

    // perform request
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(performRequest) withObject:nil afterDelay:0.1f inModes:@[NSRunLoopCommonModes] ];
}

- (void)performRequest {
    // url
    NSURL *url = [NSURL URLWithString:currentRequest.uri];

    // request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = currentRequest.httpMethod;
    request.timeoutInterval = AG_TIME_OUT;

    // http query params
    [request setURLQuery:currentRequest.httpQueryParams];

    // http header params
    [request addHTTPHeaders:currentRequest.httpHeaderParams];

    // http body
    if (![request.HTTPMethod isEqualToString:@"GET"]) {
        if (currentRequest.httpBodyFilePath) {
            NSString *filePath = [NSString stringWithFormat:@"Synchronizer/%@", currentRequest.key];
            request.HTTPBody = [NSData dataWithContentsOfFile:filePath];
        } else {
            request.HTTPBody = currentRequest.httpBody;
        }
    }

    // content-type
    if (!request.allHTTPHeaderFields[@"Content-Type"] && !request.allHTTPHeaderFields[@"content-type"]) {
        [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    }

    // user agent
    [request addValue:AGAPPLICATION.descriptor.defaultUserAgent forHTTPHeaderField:@"User-Agent"];

    // kinetise headers
    [[AGServicesManager sharedInstance].kinetiseHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];

    // session
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        // process response
        [self processHTTPResponse:httpResponse withData:data andError:error];

        // next request
        currentRequest = nil;
        [self nextRequest];
    }] resume];
}

#pragma mark - Response

- (void)processHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data andError:(NSError *)error {
    if (response.statusCode == 200) {
        // transform response
        if (isNotEmpty(currentRequest.responseTransform) ) {
            NSData *transformedData = [data jq:currentRequest.responseTransform];
            if (transformedData) {
                data = transformedData;
            }
        }

        // parse alter api response
        AGAlterApiResponse *responseObject = [AGAlterApiResponse responseWithData:data error:nil];

        // expired links
        for (NSString *expiredUri in responseObject.expiredUrls) {
            NSURL *url = [NSURL URLWithString:expiredUri];
            [[AGServicesManager sharedInstance] markURLs:url asExpired:YES];
        }

        // clean request
        [currentRequest clear];
        currentRequest.sendTimestamp = [[AGServicesManager sharedInstance] HTTPHeaderDate:response.allHeaderFields ];
        [synchronizedRequests addObject:currentRequest];
        [requests removeObject:currentRequest];
    } else {
        NSInteger index = NSNotFound;

        for (int i = 0; i < requests.count; ++i) {
            AGSynchronizerRequest *request = requests[i];
            if (request != currentRequest) {
                if ([request.key isEqualToString:currentRequest.key]) {
                    index = i;
                }
            }
        }

        if (index != NSNotFound) {
            [requests removeObject:currentRequest];
        } else {
            NSInteger currentRequestIndex = [requests indexOfObject:currentRequest];
            [requests addObject:currentRequest];
            [requests removeObjectAtIndex:currentRequestIndex];
        }
    }

    // save data
    [self saveData];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    completionHandler(request);
}

#pragma mark - Notifications

- (void)changeNetworkStatus:(NSNotification *)notification {
    Reachability *reachability = notification.object;
    NetworkStatus networkStatus = reachability.currentReachabilityStatus;

    // next request
    if (networkStatus != NotReachable) {
        [self nextRequest];
    }
}

@end
