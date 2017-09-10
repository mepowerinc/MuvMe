#import "NSDate+RFC822.h"

@implementation NSDate (RFC822)

+ (instancetype)dateFromRFC822String:(NSString *)dateString {
    if (dateString.length == 0) return nil;
    
    NSDateFormatter *dateFormatterRFC822 = [NSDateFormatter RFC822dateFormatter];
    dateString = [dateString uppercaseString];
    NSDate *date = nil;
    
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yyyy HH:mm ZZZ"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yyyy HH:mm:ss ZZZ"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yy HH:mm ZZZ"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yy HH:mm:ss ZZZ"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yyyy HH:mm"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yyyy HH:mm:ss"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yy HH:mm"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    if (!date) {
        [dateFormatterRFC822 setDateFormat:@"EEEdd MMM yy HH:mm:ss"];
        date = [dateFormatterRFC822 dateFromString:dateString];
    }
    
    return date;
}

@end

@implementation NSDateFormatter (RFC822)

+ (instancetype)RFC822dateFormatter {
    static NSDateFormatter *dateFormatterRFC822 = nil;
    static NSArray *shortWeekSymbolsRFC822 = nil;
    
    if (!shortWeekSymbolsRFC822) {
        shortWeekSymbolsRFC822 = [NSArray arrayWithObjects:@"Sun,", @"Mon,", @"Tue,", @"Wed,", @"Thu,", @"Fri,", @"Sat,", nil];
    }
    
    if (!dateFormatterRFC822) {
        dateFormatterRFC822 = [[NSDateFormatter alloc] init];
        dateFormatterRFC822.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatterRFC822.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dateFormatterRFC822 setShortWeekdaySymbols:shortWeekSymbolsRFC822];
    }
    
    return dateFormatterRFC822;
}

@end
