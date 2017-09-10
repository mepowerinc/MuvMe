#import <Foundation/Foundation.h>

@interface NSDate (HTTPHeader)

+ (instancetype)dateFromHTTPHeaderString:(NSString *)dateString;

@end
