#import <Foundation/Foundation.h>

@interface AGDateParser : NSObject

- (NSDate *)dateFromString:(NSString *)string;
- (NSTimeZone *)timezoneFromDateString:(NSString *)string;

@end
