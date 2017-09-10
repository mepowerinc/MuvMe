#import <Foundation/Foundation.h>

@interface NSDate (RFC3339)

+ (instancetype)dateFromRFC3339String:(NSString *)dateString;

@end

@interface NSTimeZone (RFC3339)

+ (instancetype)timezoneFromRFC3339String:(NSString *)dateString;

@end

@interface NSDateFormatter (RFC3339)

+ (instancetype)RFC3339dateFormatter;
+ (instancetype)RFC3339SubSecondsDateFormatter;

@end
