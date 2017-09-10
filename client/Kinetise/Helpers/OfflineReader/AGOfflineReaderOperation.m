#import "AGOfflineReaderOperation.h"
#import "AGActionManager.h"
#import "AGHTTPQueryParams.h"
#import "AGHTTPHeaderParams.h"
#import "AGApplication.h"
#import "NSString+URL.h"
#import "NSString+UriEncoding.h"
#import "NSObject+Nil.h"
#import "AGOfflineReaderImageOperation.h"
#import "AGOfflineReaderFeedXMLOperation.h"
#import "AGOfflineReaderFeedJSONOperation.h"
#import "AGServicesManager.h"

@interface AGOfflineReaderOperation () <NSURLSessionDelegate, NSURLSessionTaskDelegate>
@property(nonatomic, retain) NSURLRequest *urlRequest;
@property(nonatomic, retain) NSDictionary *json;
@end

@implementation AGOfflineReaderOperation

@synthesize urlRequest;
@synthesize json;
@synthesize delegate;

#pragma mark - Initialization

- (void)dealloc {
    self.urlRequest = nil;
    self.delegate = nil;
    self.json = nil;
    [super dealloc];
}

+ (instancetype)operationWithJSON:(NSDictionary *)json_ {
    NSString *dataType = json_[@"dataType"];

    if ([dataType isEqualToString:@"IMAGE"]) {
        return [[[AGOfflineReaderImageOperation alloc] initWithJSON:json_] autorelease];
    } else if ([dataType isEqualToString:@"XML"]) {
        return [[[AGOfflineReaderFeedXMLOperation alloc] initWithJSON:json_] autorelease];
    } else if ([dataType isEqualToString:@"JSON"]) {
        return [[[AGOfflineReaderFeedJSONOperation alloc] initWithJSON:json_] autorelease];
    }

    return nil;
}

- (id)initWithJSON:(NSDictionary *)json_ {
    self = [super init];

    // json
    self.json = json_;

    // uri
    NSString *uri = json[@"httpUrl"];
    uri = [[AGACTIONMANAGER executeString:uri withSender:nil] uriString];

    // http query params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSON:json[@"httpParams"] ];
    uri = [uri stringByAppendingURLQuery:[httpQueryParams URLQuery] ];

    // url
    NSURL *url = [NSURL URLWithString:uri];

    // url request
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:url];
    httpRequest.timeoutInterval = AG_TIME_OUT;

    // cache policy
    httpRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;

    // http method
    httpRequest.HTTPMethod = json[@"httpMethod"];

    // headers
    {
        // http header params
        NSDictionary *httpHeaderParams = [[AGHTTPHeaderParams paramsWithJSON:json[@"httpHeaderParams"] ] execute];
        [httpHeaderParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [httpRequest addValue:value forHTTPHeaderField:key];
        }];

        // user agent
        [httpRequest addValue:AGAPPLICATION.descriptor.defaultUserAgent forHTTPHeaderField:@"User-Agent"];

        // kinetise headers
        [[AGServicesManager sharedInstance].kinetiseHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [httpRequest addValue:obj forHTTPHeaderField:key];
        }];
    }

    // http body
    if (![httpRequest.HTTPMethod isEqualToString:@"GET"] && isNotNil(json[@"httpBody"]) ) {
        httpRequest.HTTPBody = [json[@"httpBody"] dataUsingEncoding:NSUTF8StringEncoding];
    }

    // url request
    self.urlRequest = httpRequest;

    return self;
}

#pragma mark - Lifecycle

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) return;

        NSLog(@"%@", urlRequest.URL);

        // synchronous session
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];

        [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

            // process response
            if (!self.isCancelled) {
                [self processRequest:urlRequest withResponse:httpResponse data:data andError:error];
            }

            dispatch_semaphore_signal(semaphore);
        }] resume];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
    }
}

#pragma mark - Processing

- (void)processRequest:(NSURLRequest *)request withResponse:(NSHTTPURLResponse *)response data:(NSData *)data andError:(NSError *)error {
    if (response.statusCode >= 200 && response.statusCode < 400) {
        // force caching
        NSCachedURLResponse *responseForCaching = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        [[NSURLCache sharedURLCache] storeCachedResponse:responseForCaching forRequest:request];
        [responseForCaching release];

        // success
        [self onSuccess:nil];
    } else {
        [self onFail:error];
    }
}

- (void)onSuccess:(NSArray *)operations {
    // delegate
    if (![NSThread isMainThread]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([delegate respondsToSelector:@selector(offlineReaderOperation:didEndWithOperations:andError:)]) {
                [delegate offlineReaderOperation:self didEndWithOperations:operations andError:nil];
            }
        }];
    } else {
        if ([delegate respondsToSelector:@selector(offlineReaderOperation:didEndWithOperations:andError:)]) {
            [delegate offlineReaderOperation:self didEndWithOperations:operations andError:nil];
        }
    }
}

- (void)onFail:(NSError *)error {
    NSLog(@"[Offline reading] Failed url: %@", json[@"httpUrl"]);

    // error
    if (!error) {
        error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    }

    // delegate
    if (![NSThread isMainThread]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([self.delegate respondsToSelector:@selector(offlineReaderOperation:didEndWithOperations:andError:)]) {
                [self.delegate offlineReaderOperation:self didEndWithOperations:nil andError:error];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(offlineReaderOperation:didEndWithOperations:andError:)]) {
            [self.delegate offlineReaderOperation:self didEndWithOperations:nil andError:error];
        }
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

#pragma mark - NSCompare

- (BOOL)isEqualToOfflineReaderOperation:(AGOfflineReaderOperation *)object {
    if (![json[@"dataType"] isEqualToString:object.json[@"dataType"]]) return NO;
    if (![json[@"httpUrl"] isEqualToString:object.json[@"httpUrl"]]) return NO;
    if (![json[@"httpParams"] isEqual:object.json[@"httpParams"]]) return NO;
    if (![json[@"httpHeaderParams"] isEqual:object.json[@"httpHeaderParams"]]) return NO;
    if (![json[@"httpMethod"] isEqualToString:object.json[@"httpMethod"]]) return NO;
    if (![json[@"httpBody"] isEqualToString:object.json[@"httpBody"]]) return NO;

    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[AGOfflineReaderOperation class]]) {
        return NO;
    }

    return [self isEqualToOfflineReaderOperation:(AGOfflineReaderOperation *)object];
}

@end
