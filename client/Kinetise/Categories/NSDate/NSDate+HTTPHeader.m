#import "NSDate+HTTPHeader.h"
#import "NSDate+RFC1123.h"
#import "NSDate+RFC850.h"
#import "NSDate+ASCTIME.h"

@implementation NSDate (HTTPHeader)

+ (instancetype)dateFromHTTPHeaderString:(NSString *)dateString {
    NSDate *date = [NSDate dateFromRFC1123String:dateString];
    if (!date) date = [NSDate dateFromRFC850String:dateString];
    if (!date) date = [NSDate dateFromASCTIMEString:dateString];

    return date;
}

@end
