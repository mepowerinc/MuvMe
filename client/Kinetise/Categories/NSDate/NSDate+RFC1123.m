#import "NSDate+RFC1123.h"

@implementation NSDate (RFC1123)

+ (instancetype)dateFromRFC1123String:(NSString *)dateString {
    NSDateFormatter *dateFormatterRFC1123 = [NSDateFormatter RFC1123dateFormatter];

    return [dateFormatterRFC1123 dateFromString:dateString];
}

@end

@implementation NSDateFormatter (RFC1123)

+ (instancetype)RFC1123dateFormatter {
    static NSDateFormatter *dateFormatterRFC1123 = nil;

    if (!dateFormatterRFC1123) {
        dateFormatterRFC1123 = [[NSDateFormatter alloc] init];
        dateFormatterRFC1123.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatterRFC1123.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatterRFC1123.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss z";
    }

    return dateFormatterRFC1123;
}

@end
