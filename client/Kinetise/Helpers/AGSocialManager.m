#import "AGSocialManager.h"
#import <FXKeychain/FXKeychain.h>
#import "AGReachability.h"
#import "NSString+URL.h"
#import "NSString+Base64.h"

#define FB_TOKEN_KEY @"fb_token"
#define TW_TOKEN_KEY @"tw_token"

@interface AGSocialManager (){
    AGSocialService services;
    NSOperationQueue *operationQueue;
    NSString *facebookAccessToken;
    NSString *twitterAccessToken;
}
@property(nonatomic, copy) NSString *facebookAccessToken;
@property(nonatomic, copy) NSString *twitterAccessToken;
@property(nonatomic, copy) void (^completionBlock)();
@end

@implementation AGSocialManager

@synthesize services;
@synthesize facebookAccessToken;
@synthesize twitterAccessToken;
@synthesize completionBlock;

SINGLETON_IMPLEMENTATION(AGSocialManager)

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [operationQueue removeObserver:self forKeyPath:@"operations"];
    [operationQueue cancelAllOperations];
    [operationQueue release];
    self.facebookAccessToken = nil;
    self.twitterAccessToken = nil;
    self.completionBlock = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // services
    services = AGSocialServiceNone;

    // operation queue
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;

    // tokens
    self.facebookAccessToken = [[FXKeychain defaultKeychain] objectForKey:FB_TOKEN_KEY];
    self.twitterAccessToken = [[FXKeychain defaultKeychain] objectForKey:TW_TOKEN_KEY];

    // observer
    [operationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];

    // notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    return self;
}

#pragma mark - Lifecycle

- (void)getAccessTokens:(void (^)())completionBlock_ {
    self.completionBlock = completionBlock_;

    [self updateAccessTokens];
}

- (void)updateAccessTokens {
    if (operationQueue.operationCount > 0) {
        return;
    }

    if (services&AGSocialServiceFacebook) {
        [self updateFBAccessToken];
    }
    if (services&AGSocialServiceTwitter) {
        [self updateTWAccessToken];
    }
}

- (void)updateFBAccessToken {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        // url
        NSString *uri = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/access_token?client_id=%@&client_secret=%@&grant_type=client_credentials", AG_FB_APP_ID, AG_FB_APP_SECRET];
        NSURL *url = [NSURL URLWithString:uri];

        // request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 5;

        // session
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

            if (httpResponse.statusCode == 200 && [responseString hasPrefix:@"access_token="]) {
                @synchronized(facebookAccessToken) {
                    self.facebookAccessToken = [responseString stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
                }
                [[FXKeychain defaultKeychain] setObject:facebookAccessToken forKey:FB_TOKEN_KEY];
            } else {
                NSLog(@"Could not get fb access token: %@", [error localizedDescription]);
            }

            dispatch_semaphore_signal(semaphore);
        }] resume];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];

    [operationQueue addOperation:operation];
}

- (void)updateTWAccessToken {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        // token
        NSString *token = [NSString stringWithFormat:@"%@:%@", AG_TWITTER_APP_KEY, AG_TWITTER_APP_SECRET];
        token = [token base64EncodedString];
        token = [NSString stringWithFormat:@"Basic %@", token];

        // url
        NSString *uri = [NSString stringWithFormat:@"https://api.twitter.com/oauth2/token"];
        uri = [uri stringByAppendingURLQuery:[NSString stringWithFormat:@"%@=%@", @"grant_type", @"client_credentials"] ];
        NSURL *url = [NSURL URLWithString:uri];

        // request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 5;
        [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:token forHTTPHeaderField:@"Authorization"];

        // session
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *responseObject = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;

            if (httpResponse.statusCode == 200 && responseObject[@"access_token"] && responseObject[@"token_type"]) {
                @synchronized(twitterAccessToken) {
                    self.twitterAccessToken = [NSString stringWithFormat:@"%@ %@", responseObject[@"token_type"], responseObject[@"access_token"] ];
                }
                [[FXKeychain defaultKeychain] setObject:twitterAccessToken forKey:TW_TOKEN_KEY];
            } else {
                NSLog(@"Could not get tw access token: %@", [error localizedDescription]);
            }

            dispatch_semaphore_signal(semaphore);
        }] resume];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];

    [operationQueue addOperation:operation];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView *)scrollView change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operations"] && operationQueue.operationCount == 0) {
        if (completionBlock) {
            completionBlock();
            self.completionBlock = nil;
        }
    }
}

#pragma mark - Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self updateAccessTokens];
}

- (void)changeNetworkStatus:(NSNotification *)notification {
    Reachability *reachability = [notification object];
    NetworkStatus networkStatus = reachability.currentReachabilityStatus;

    if (networkStatus != NotReachable) {
        [self updateAccessTokens];
    }
}

@end
