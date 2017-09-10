#import <Foundation/Foundation.h>

@interface NSDate (RFC822)

+ (instancetype)dateFromRFC822String:(NSString *)dateString;

@end

@interface NSDateFormatter (RFC822)

+ (instancetype)RFC822dateFormatter;

@end
