#import "AGAsset.h"
#import "GDataXMLNode+XPath.h"
#import "AGApplication.h"
#import "AGApplication+Authentication.h"
#import "NSString+URL.h"
#import "NSString+UriEncoding.h"
#import "AGReachability.h"
#import "AGActionManager.h"
#import "AGServicesManager.h"
#import "AGLocalizationManager.h"
#import "AGApplication+Popup.h"
#import "AGServicesManager.h"
#import "AGAssetsManager.h"

@interface AGAsset () <NSURLSessionDataDelegate>{
    AGCachePolicy tempCachePolicy;
    NSTimeInterval deltaTime;
}
@property(nonatomic, retain) NSURLSessionDataTask *sessionDataTask;
@property(nonatomic, retain) NSURLRequest *originalRequest;
@property(nonatomic, copy) NSString *lastUpdateToken;
@end

@implementation AGAsset

@synthesize uri;
@synthesize httpMethod;
@synthesize httpQueryParams;
@synthesize httpHeaderParams;
@synthesize httpBody;
@synthesize cachePolicy;
@synthesize cacheInterval;
@synthesize delegate;

@synthesize assetType;
@synthesize isCachedData;
@synthesize isSilentRequest;
@synthesize lastUpdateToken;
@synthesize sessionDataTask;
@synthesize originalRequest;

#pragma mark - Initialization

- (void)dealloc {
    [self clearDelegatesAndCancel];
    self.uri = nil;
    self.httpMethod = nil;
    self.httpQueryParams = nil;
    self.httpHeaderParams = nil;
    self.httpBody = nil;
    self.lastUpdateToken = nil;
    self.sessionDataTask = nil;
    self.originalRequest = nil;
    [super dealloc];
}

- (id)initWithUri:(NSString *)uri_ {
    self = [super init];

    // uri
    self.uri = uri_;

    // cache policy
    cachePolicy = cachePolicyDefault;

    return self;
}

#pragma mark - Lifecycle

- (void)setUri:(NSString *)uri_ {
    if ([uri isEqualToString:uri_]) return;

    [uri release];
    uri = [uri_ copy];

    if (uri) {
        // asset type
        assetType = assetUnknown;
        if ([uri hasPrefix:@"assets://"]) {
            assetType = assetFile;
        } else if ([uri isEqualToString:@"control://context"]) {
            assetType = assetContext;
        } else if ([uri hasPrefix:@"local://"]) {
            assetType = assetLocalStorage;
        } else if ([uri hasPrefix:@"http"]) {
            assetType = assetHttp;
        }
    }
}

#pragma mark - Execution

- (void)execute {
    // stop all operations from previous execution
    [self cancel];

    // http cache
    NSCachedURLResponse *cachedResponse = nil;

    // http
    if (assetType == assetHttp) {
        // url
        NSString *URLQuery = [NSString URLQueryWithParameters:httpQueryParams];
        NSURL *url = [NSURL URLWithString:[uri stringByAppendingURLQuery:URLQuery] ];

        // expired
        if ([[AGServicesManager sharedInstance] isExpiredURL:url]) {
            tempCachePolicy = cachePolicy;
            cachePolicy = cachePolicyForceReload;
        }

        // request
        self.originalRequest = [self requestWithURL:url andCachePolicy:cachePolicy];

        // cache data
        BOOL allowCachedData = YES;

        if (cachePolicy == cachePolicyForceReload || cachePolicy == cachePolicyFreshData || cachePolicy == cachePolicyRefreshEvery) {
            allowCachedData = NO;
        } else if (cachePolicy == cachePolicyMaxAge && [[AGServicesManager sharedInstance] deltaTimeForURL:originalRequest.URL] > cacheInterval) {
            allowCachedData = NO;
        }

        if (allowCachedData) {
            cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:originalRequest];

            if (cachedResponse && ((NSHTTPURLResponse *)cachedResponse.response).statusCode == 200) {
                [self processCachedResponse:cachedResponse];
                isCachedData = cachedResponse.data.length > 0;

                if (!isCachedData) {
                    NSLog(@"No data in cache response");
                }
            }
        }
    }

    // delegate
    [delegate assetWillLoad:self];

    // none
    if (assetType == assetUnknown) {
        [delegate asset:self didFail:nil];
    }

    // http
    if (assetType == assetHttp) {
        if (isCachedData) {
            [self processData:cachedResponse.data asynchronous:NO];
        } else {
            [self startHttpRequest];
        }
    }
}

- (void)cancel {
    isCachedData = NO;
    isSilentRequest = NO;
    [self cancelScheduledHttpRequest];

    [sessionDataTask cancel];
    self.sessionDataTask = nil;
}

- (void)clearDelegatesAndCancel {
    self.delegate = nil;
    [self cancel];
}

#pragma mark - Request

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url andCachePolicy:(AGCachePolicy)cachePolicy_ {
    // request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.timeoutInterval = AG_TIME_OUT;

    // http method
    if (httpMethod) {
        urlRequest.HTTPMethod = httpMethod;
    }

    // cache
    {
        // default cache policy
        urlRequest.cachePolicy = NSURLRequestUseProtocolCachePolicy;

        // no Internet connection
        if ([AGReachability sharedInstance].reachability.currentReachabilityStatus == NotReachable) {
            urlRequest.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
        }

        // cache - force reload
        if (cachePolicy_ == cachePolicyForceReload) {
            urlRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        }

        // cache - do not cache
        if (cachePolicy_ == cachePolicyDoNotCache) {
            urlRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        }

        // cache - live
        if (cachePolicy_ == cachePolicyLiveStream && isSilentRequest) {
            urlRequest.timeoutInterval = INFINITY;
        }
    }

    // http headers
    {
        // http header params
        [httpHeaderParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [urlRequest addValue:value forHTTPHeaderField:key];
        }];

        // user agent
        [urlRequest addValue:AGAPPLICATION.descriptor.defaultUserAgent forHTTPHeaderField:@"User-Agent"];

        // kinetise headers
        [[AGServicesManager sharedInstance].kinetiseHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [urlRequest addValue:obj forHTTPHeaderField:key];
        }];
    }

    // http body
    if (![urlRequest.HTTPMethod isEqualToString:@"GET"]) {
        urlRequest.HTTPBody = httpBody;
    }

    return urlRequest;
}

- (void)scheduleHttpRequestAfterDelay:(CGFloat)delay {
    // delegate
    if ([delegate respondsToSelector:@selector(assetWillLoadSilent:)]) {
        [delegate assetWillLoadSilent:self];
    }

    // url
    NSString *URLQuery = [NSString URLQueryWithParameters:httpQueryParams];
    NSURL *url = [NSURL URLWithString:[uri stringByAppendingURLQuery:URLQuery] ];

    // request
    self.originalRequest = [self requestWithURL:url andCachePolicy:cachePolicy];

    // schedule request
    isSilentRequest = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startHttpRequest) withObject:nil afterDelay:delay inModes:@[NSRunLoopCommonModes] ];
}

- (void)cancelScheduledHttpRequest {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startHttpRequest) object:nil];
}

- (void)startHttpRequest {
    // cancel previus task
    [sessionDataTask cancel];
    self.sessionDataTask = nil;

    // request
    NSURLRequest *internalRequest = originalRequest;

    // cache - live
    if (cachePolicy == cachePolicyLiveStream && isSilentRequest) {
        NSMutableURLRequest *newRequest = [[internalRequest mutableCopy] autorelease];
        NSString *longpollingURLQuery = [NSString stringWithFormat:@"longpolling=true&lastupdatetoken=%@", lastUpdateToken ? lastUpdateToken : @"" ];
        NSString *newUri = [[newRequest.URL absoluteString] stringByMergingURLQuery:longpollingURLQuery];
        newRequest.URL = [NSURL URLWithString:newUri];
        internalRequest = newRequest;
    }

    // data task
    self.sessionDataTask = [[AGAssetsManager sharedInstance] dataTask:assetDataType silent:isSilentRequest request:internalRequest delegate:self completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error){
        [self processHTTPResponse:(NSHTTPURLResponse *)response withData:data andError:error];
        self.sessionDataTask = nil;
    }];
    [sessionDataTask resume];

#ifdef DEBUG
    // log
    NSLog(@"%@", internalRequest.URL);
#endif
}

#pragma mark - Response

- (void)processHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data andError:(NSError *)error {
    //NSLog(@"url: %@\nresponse code: %zd\nerror: %@\n%@", response.URL, response.statusCode, error, data.length<1024*10 ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : @"data bigger than 10KB" );

    // cancelled
    if (error.code == NSURLErrorCancelled) {
        return;
    }

    // !!!
    // cached response
    BOOL didUseCache = NO;

    // force caching
    if (response.statusCode == 200 && !didUseCache && cachePolicy != cachePolicyDoNotCache) {
        NSCachedURLResponse *responseForCaching = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        [[NSURLCache sharedURLCache] storeCachedResponse:responseForCaching forRequest:originalRequest];
        [responseForCaching release];
    }

    // time from previous success request
    deltaTime = [[AGServicesManager sharedInstance] deltaTimeForURL:originalRequest.URL];

    // update timestamp
    if (response.statusCode >= 200 && response.statusCode < 400) {
        [[AGServicesManager sharedInstance] setTimestamp:[NSDate date] forURL:originalRequest.URL];
    }

    // expired
    [[AGServicesManager sharedInstance] markURL:originalRequest.URL asExpired:NO];

    // silent response
    if (isSilentRequest) {
        if (cachePolicy == cachePolicyCachedData) {
            return;
        }
        if (cachePolicy == cachePolicyCachedDataWithRefresh && (didUseCache || response.statusCode < 200 || response.statusCode >= 400 || error) ) {
            return;
        }
        if ( (cachePolicy == cachePolicyRefreshEvery || cachePolicy == cachePolicyCachedDataWithRefreshEvery) && (didUseCache || response.statusCode < 200 || response.statusCode >= 400 || error) ) {
            NSTimeInterval delay = MAX(cacheInterval-deltaTime, 0);
            [self scheduleHttpRequestAfterDelay:delay];
            return;
        }
        if (cachePolicy == cachePolicyLiveStream && (didUseCache || response.statusCode < 200 || response.statusCode >= 400 || error) ) {
            [self scheduleHttpRequestAfterDelay:0];
            return;
        }
    }

    // cache - force reload
    if (cachePolicy == cachePolicyForceReload) {
        cachePolicy = tempCachePolicy;
    }

    // process data
    if (response.statusCode >= 200 && response.statusCode < 400) {
        // last update token
        if (cachePolicy == cachePolicyLiveStream && !isCachedData) {
            self.lastUpdateToken = response.allHeaderFields[@"X-Kinetise-Last-Update-Token"];
        }

        // process data
        [self processData:data asynchronous:YES];
    } else {
        // cache data
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:originalRequest];
        NSData *cachedData = cachedResponse.data;
        [self processCachedResponse:cachedResponse];

        if (cachedData.length) {
            isCachedData = YES;
            [self processData:cachedData asynchronous:YES];

            if (assetDataType == assetFeedData) {
                [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"ERROR_DATA_FROM_CACHE"] ];
            }
        } else {
            // delegate
            [delegate asset:self didFail:nil];

            // cache - refresh every
            if (cachePolicy == cachePolicyRefreshEvery || cachePolicy == cachePolicyCachedDataWithRefreshEvery) {
                NSTimeInterval delay = MAX(cacheInterval-deltaTime, 0);
                [self scheduleHttpRequestAfterDelay:delay];
            }

            // cache - live
            if (cachePolicy == cachePolicyLiveStream) {
                [self scheduleHttpRequestAfterDelay:0];
            }
        }
    }
}

- (void)processCachedResponse:(NSCachedURLResponse *)cachedResponse {
    if (cachePolicy == cachePolicyLiveStream) {
        NSHTTPURLResponse *HTTPCachedResponse = (NSHTTPURLResponse *)cachedResponse.response;
        self.lastUpdateToken = HTTPCachedResponse.allHeaderFields[@"X-Kinetise-Last-Update-Token"];
    }
}

- (void)processData:(NSData *)data asynchronous:(BOOL)async {

}

- (void)finishProcessingData {
    // cache data
    if (isCachedData) {
        isCachedData = NO;

        if (cachePolicy == cachePolicyCachedData || cachePolicy == cachePolicyCachedDataWithRefresh) {
            [self scheduleHttpRequestAfterDelay:0];
        }
    }

    // cache - refresh every
    if (cachePolicy == cachePolicyRefreshEvery || cachePolicy == cachePolicyCachedDataWithRefreshEvery) {
        NSTimeInterval delay = MAX(cacheInterval-deltaTime, 0);
        [self scheduleHttpRequestAfterDelay:delay];
    }

    // cache - live
    if (cachePolicy == cachePolicyLiveStream) {
        [self scheduleHttpRequestAfterDelay:0];
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler {
    if (cachePolicy == cachePolicyDoNotCache) {
        proposedResponse = [[[NSCachedURLResponse alloc] initWithResponse:proposedResponse.response
                                                                     data:proposedResponse.data
                                                                 userInfo:proposedResponse.userInfo
                                                            storagePolicy:NSURLCacheStorageNotAllowed] autorelease];
    }

    completionHandler(proposedResponse);
}

@end
