#import "NSDate+RFC3339.h"

@implementation NSDate (RFC3339)

+ (instancetype)dateFromRFC3339String:(NSString *)dateString {
    if (dateString.length == 0) return nil;
    
    NSDateFormatter *dateFormatterRFC3339 = [NSDateFormatter RFC3339dateFormatter];
    NSDateFormatter *dateFormatterRFC3339SubSeconds = [NSDateFormatter RFC3339SubSecondsDateFormatter];
    NSDate *date = nil;
    
    if ([dateString rangeOfString:@"."].location != NSNotFound) {
        date = [dateFormatterRFC3339SubSeconds dateFromString:dateString];
    } else {
        date = [dateFormatterRFC3339 dateFromString:dateString];
    }
    
    return date;
}

@end

@implementation NSTimeZone (RFC3339)

+ (instancetype)timezoneFromRFC3339String:(NSString *)dateString {
    if (dateString.length == 0) return [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    dateString = [dateString uppercaseString];
    
    if ([dateString hasSuffix:@"Z"]) {
        return [NSTimeZone timeZoneForSecondsFromGMT:0];
    } else {
        NSString *timeZoneStr = [dateString substringFromIndex:(dateString.length-6)];
        int sign = 0;
        
        if ([timeZoneStr characterAtIndex:0] == '+') {
            sign = 1;
        } else {
            sign = -1;
        }
        
        timeZoneStr = [timeZoneStr substringFromIndex:1];
        NSInteger hours = [[timeZoneStr substringWithRange:NSMakeRange(0, 2)] integerValue];
        NSInteger minutes = [[timeZoneStr substringWithRange:NSMakeRange(3, 2)] integerValue];
        
        NSInteger seconds = sign * (minutes * 60 + hours * 60 * 60);
        
        return [NSTimeZone timeZoneForSecondsFromGMT:seconds];
    }
}

@end

@implementation NSDateFormatter (RFC3339)

+ (instancetype)RFC3339dateFormatter {
    static NSDateFormatter *dateFormatterRFC3339 = nil;
    
    // yyyy-MM-dd'T'HH:mm:ssZZZZZ
    if (!dateFormatterRFC3339) {
        dateFormatterRFC3339 = [[NSDateFormatter alloc] init];
        dateFormatterRFC3339.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatterRFC3339.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatterRFC3339.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssXXX";
    }
    
    return dateFormatterRFC3339;
}

+ (instancetype)RFC3339SubSecondsDateFormatter {
    static NSDateFormatter *dateFormatterRFC3339SubSeconds = nil;
    
    // yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZZ
    if (!dateFormatterRFC3339SubSeconds) {
        dateFormatterRFC3339SubSeconds = [[NSDateFormatter alloc] init];
        dateFormatterRFC3339SubSeconds.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatterRFC3339SubSeconds.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatterRFC3339SubSeconds.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX";
    }
    
    return dateFormatterRFC3339SubSeconds;
}

@end
