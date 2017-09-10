#import <Foundation/Foundation.h>

@interface NSDate (ASCTIME)

+ (instancetype)dateFromASCTIMEString:(NSString *)dateString;

@end

@interface NSDateFormatter (ASCTIME)

+ (instancetype)ASCTIMEdateFormatter;

@end
