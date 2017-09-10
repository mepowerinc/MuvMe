#import <Foundation/Foundation.h>

@interface NSDate (RFC850)

+ (instancetype)dateFromRFC850String:(NSString *)dateString;

@end

@interface NSDateFormatter (RFC850)

+ (instancetype)RFC850dateFormatter;

@end
