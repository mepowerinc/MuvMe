#import "NSObject+Singleton.h"

@interface AGServicesManager : NSObject

    SINGLETON_INTERFACE(AGServicesManager)

@property(nonatomic, readonly) NSDictionary *kinetiseHeaders;

- (void)clearCache;
- (BOOL)isExpiredURL:(NSURL *)url;
- (void)markURLsAsExpired:(BOOL)isExpired;
- (void)markURL:(NSURL *)url asExpired:(BOOL)isExpired;
- (void)markURLs:(NSURL *)urlPrefix asExpired:(BOOL)isExpired;
- (void)setTimestamp:(NSDate *)timestamp forURL:(NSURL *)url;
- (NSDate *)timestampForURL:(NSURL *)url;
- (NSTimeInterval)deltaTimeForURL:(NSURL *)url;
- (NSDate *)HTTPHeaderDate:(NSDictionary *)HTTPHeaders;

@end
