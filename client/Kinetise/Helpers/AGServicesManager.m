#import "AGServicesManager.h"
#import "UIDevice+Hardware.h"
#import "AGApplication.h"
#import "AGDataProvider.h"
#import "NSDate+HTTPHeader.h"

@interface AGServicesManager (){
    NSMutableDictionary *kinetiseHeaders;
}
@end

@implementation AGServicesManager

@synthesize kinetiseHeaders;

SINGLETON_IMPLEMENTATION(AGServicesManager)

#pragma mark - Initialization

- (void)dealloc {
    [kinetiseHeaders release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // shared url cache
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024 diskCapacity:100*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];

    // kinetise headers
    kinetiseHeaders = [[NSMutableDictionary alloc] init];
    kinetiseHeaders[@"X-Kinetise-OS"] = @"iOS";
    kinetiseHeaders[@"X-Kinetise-OS-Version"] = [[UIDevice currentDevice] systemVersion];
    kinetiseHeaders[@"X-Kinetise-Device"] = [[UIDevice currentDevice] hardwareString];
    kinetiseHeaders[@"X-Kinetise-App-Name"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    kinetiseHeaders[@"X-Kinetise-App-Version"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    return self;
}

#pragma mark - Lifecycle

- (NSDictionary *)kinetiseHeaders {
    if ([AGApplication isAllocated]) {
        kinetiseHeaders[@"X-Kinetise-API-Version"] = AGAPPLICATION.descriptor.apiVersion;
    }

    return kinetiseHeaders;
}

- (void)clearCache {
    [self clearExpiredURLs];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)isExpiredURL:(NSURL *)url {
    BOOL isExpired = NO;

    FMResultSet *s = [DATABASE executeQuery:@"SELECT isExpired FROM Service WHERE Url=?", url.absoluteString];
    while ([s next]) {
        isExpired = [s boolForColumnIndex:0];
    }

    return isExpired;
}

- (void)clearExpiredURLs {
    [DATABASE executeUpdate:@"DELETE FROM Service"];
}

- (void)markURLsAsExpired:(BOOL)isExpired {
    [DATABASE executeUpdate:@"UPDATE Service SET IsExpired=?", @(isExpired)];
}

- (void)markURL:(NSURL *)url asExpired:(BOOL)isExpired {
    [DATABASE executeUpdate:@"UPDATE Service SET IsExpired=? WHERE Url=?", @(isExpired), url.absoluteString];
}

- (void)markURLs:(NSURL *)urlPrefix asExpired:(BOOL)isExpired {
    [DATABASE executeUpdate:@"UPDATE Service SET IsExpired=? WHERE Url LIKE ?", @(isExpired), [NSString stringWithFormat:@"%@%%", urlPrefix] ];
}

- (void)setTimestamp:(NSDate *)timestamp forURL:(NSURL *)url {
    [DATABASE executeUpdate:@"INSERT OR IGNORE INTO Service (Url, Timestamp) VALUES (?, ?)", url.absoluteString, timestamp];
    [DATABASE executeUpdate:@"UPDATE Service SET Timestamp=? WHERE Url=?", timestamp, url.absoluteString];
}

- (NSDate *)timestampForURL:(NSURL *)url {
    NSDate *timestamp = [NSDate distantPast];

    FMResultSet *s = [DATABASE executeQuery:@"SELECT Timestamp FROM Service WHERE Url=?", url.absoluteString];
    while ([s next]) {
        timestamp = [s dateForColumnIndex:0];
    }

    return timestamp;
}

- (NSTimeInterval)deltaTimeForURL:(NSURL *)url {
    NSDate *timestamp = [NSDate distantPast];

    FMResultSet *s = [DATABASE executeQuery:@"SELECT Timestamp FROM Service WHERE Url=?", url.absoluteString];
    while ([s next]) {
        timestamp = [s dateForColumnIndex:0];
    }

    return [[NSDate date] timeIntervalSinceDate:timestamp];
}

- (NSDate *)HTTPHeaderDate:(NSDictionary *)HTTPHeaders {
    if (!HTTPHeaders) return [NSDate date];

    NSString *dateString = HTTPHeaders[@"Date"];
    if (!dateString) dateString = HTTPHeaders[@"date"];
    if (!dateString) return [NSDate date];

    NSDate *date = [NSDate dateFromHTTPHeaderString:dateString];
    if (!date) date = [NSDate date];

    return date;
}

@end
