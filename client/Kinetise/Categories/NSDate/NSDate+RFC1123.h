#import <Foundation/Foundation.h>

@interface NSDate (RFC1123)

+ (instancetype)dateFromRFC1123String:(NSString *)dateString;

@end

@interface NSDateFormatter (RFC1123)

+ (instancetype)RFC1123dateFormatter;

@end
