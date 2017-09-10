#import "AGRFC3339DateParser.h"

@implementation AGRFC3339DateParser {
    NSDateFormatter *dateFormatter;
    BOOL formatHasFracSec;
    NSString *formatWithFracSec;
    NSString *formatWithoutFracSec;
}

- (void)dealloc {
    [dateFormatter release];
    [formatWithFracSec release];
    [formatWithoutFracSec release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    dateFormatter = [[NSDateFormatter alloc] init];

    // locale
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [locale release];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    formatWithFracSec = [@"yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZZ" retain];
    formatWithoutFracSec = [@"yyyy-MM-dd'T'HH:mm:ssZZZZZ" retain];

    // date format
    formatHasFracSec = NO;
    [dateFormatter setDateFormat:formatWithoutFracSec];

    return self;
}

- (NSDate *)dateFromString:(NSString *)string {
    if (string.length == 0) return nil;

    string = [string uppercaseString];
    BOOL hasFracSec = ([string rangeOfString:@"."].location != NSNotFound);
    if (hasFracSec && !formatHasFracSec) {
        formatHasFracSec = YES;
        [dateFormatter setDateFormat:formatWithFracSec];
    } else if (!hasFracSec && formatWithFracSec) {
        formatHasFracSec = NO;
        [dateFormatter setDateFormat:formatWithoutFracSec];
    }

    return [dateFormatter dateFromString:string];
}

- (NSTimeZone *)timezoneFromDateString:(NSString *)string {
    if (string.length == 0) return [NSTimeZone timeZoneForSecondsFromGMT:0];

    string = [string uppercaseString];
    if ([string hasSuffix:@"Z"]) {
        return [NSTimeZone timeZoneForSecondsFromGMT:0];
    } else {
        NSString *timeZoneStr = [string substringFromIndex:([string length] - 6)];
        int sign = 0;
        if ([timeZoneStr characterAtIndex:0] == '+')
            sign = 1;
        else
            sign = -1;

        timeZoneStr = [timeZoneStr substringFromIndex:1];
        NSInteger hours = [[timeZoneStr substringWithRange:NSMakeRange(0, 2)] integerValue];
        NSInteger minutes = [[timeZoneStr substringWithRange:NSMakeRange(3, 2)] integerValue];

        NSInteger seconds = sign * (minutes * 60 + hours * 60 * 60);

        return [NSTimeZone timeZoneForSecondsFromGMT:seconds];
    }
}

@end
