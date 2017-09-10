#import "AGHTTPQueryParams.h"
#import "NSString+URL.h"

@implementation AGHTTPQueryParams

- (NSString *)URLQuery {
    return [NSString URLQueryWithParameters:[self execute] ];
}

@end
