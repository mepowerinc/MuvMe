#import "NSDate+ASCTIME.h"

@implementation NSDate (ASCTIME)

+ (instancetype)dateFromASCTIMEString:(NSString *)dateString {
    NSDateFormatter *dateFormatterASCTIME = [NSDateFormatter ASCTIMEdateFormatter];

    return [dateFormatterASCTIME dateFromString:dateString];
}

@end

@implementation NSDateFormatter (ASCTIME)

+ (instancetype)ASCTIMEdateFormatter {
    static NSDateFormatter *dateFormatterASCTIME = nil;

    if (!dateFormatterASCTIME) {
        dateFormatterASCTIME = [[NSDateFormatter alloc] init];
        dateFormatterASCTIME.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatterASCTIME.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatterASCTIME.dateFormat = @"EEE MMM d HH':'mm':'ss yyyy";
    }

    return dateFormatterASCTIME;
}

@end
