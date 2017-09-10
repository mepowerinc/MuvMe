#import "NSDate+RFC850.h"

@implementation NSDate (RFC850)

+ (instancetype)dateFromRFC850String:(NSString *)dateString {
    NSDateFormatter *dateFormatterRFC850 = [NSDateFormatter RFC850dateFormatter];

    return [dateFormatterRFC850 dateFromString:dateString];
}

@end

@implementation NSDateFormatter (RFC850)

+ (instancetype)RFC850dateFormatter {
    static NSDateFormatter *dateFormatterRFC850 = nil;

    if (!dateFormatterRFC850) {
        dateFormatterRFC850 = [[NSDateFormatter alloc] init];
        dateFormatterRFC850.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatterRFC850.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatterRFC850.dateFormat = @"EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z";
    }

    return dateFormatterRFC850;
}

@end