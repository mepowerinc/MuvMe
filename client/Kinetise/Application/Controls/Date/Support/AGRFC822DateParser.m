#import "AGRFC822DateParser.h"

@implementation AGRFC822DateParser {
    NSDateFormatter *dateFormatter;
    NSArray *dateFormats;
    NSUInteger currentFormat;
    NSArray *weekdays;
    NSDictionary *timezones;
    NSDictionary *timeZonesOffsets;
}

- (void)dealloc {
    [dateFormatter release];
    [dateFormats release];
    [weekdays release];
    [timezones release];
    [timeZonesOffsets release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // locale
    dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [locale release];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    // date formats
    dateFormats = [[NSArray alloc] initWithObjects:
                   @"dd MMM yyyy HH:mm ZZZ",              //ex. 03 Sep 2012 01:00 GMT
                   @"dd MMM yyyy HH:mm:ss ZZZ",         //ex. 03 Sep 2012 01:00:39 GMT
                   @"dd MMM yy HH:mm ZZZ",                //ex. 03 Sep 12 01:00 GMT
                   @"dd MMM yy HH:mm:ss ZZZ",           //ex. 03 Sep 12 01:00:39 GMT
                   @"dd MMM yyyy HH:mm",              //ex. 03 Sep 2012 01:00
                   @"dd MMM yyyy HH:mm:ss",         //ex. 03 Sep 2012 01:00:39
                   @"dd MMM yy HH:mm",                //ex. 03 Sep 12 01:00
                   @"dd MMM yy HH:mm:ss",           //ex. 03 Sep 12 01:00:39
                   nil];
    currentFormat = 0;
    [dateFormatter setDateFormat:dateFormats[currentFormat]];

    // weekdays
    weekdays = [@[@"Mon, ", @"Tue, ", @"Wed, ", @"Thu, ", @"Fri, ", @"Sat, ", @"Sun, "] retain];

    // timezones
    timezones = [@{
                     @" EST" : @" -0500",
                     @" EDT" : @" -0400",
                     @" CST" : @" -0600",
                     @" CDT" : @" -0500",
                     @" MST" : @" -0700",
                     @" MDT" : @" -0600",
                     @" PST" : @" -0800",
                     @" PDT" : @" -0700",
                     @" Y"   : @" -1200",
                     @" X"   : @" -1100",
                     @" W"   : @" -1000",
                     @" V"   : @" -0900",
                     @" U"   : @" -0800",
                     @" T"   : @" -0700",
                     @" S"   : @" -0600",
                     @" R"   : @" -0500",
                     @" Q"   : @" -0400",
                     @" P"   : @" -0300",
                     @" O"   : @" -0200",
                     @" N"   : @" -0100",
                     @" Z"   : @" UT",
                     @" A"   : @" +0100",
                     @" B"   : @" +0200",
                     @" C"   : @" +0300",
                     @" D"   : @" +0400",
                     @" E"   : @" +0500",
                     @" F"   : @" +0600",
                     @" G"   : @" +0700",
                     @" H"   : @" +0800",
                     @" I"   : @" +0900",
                     @" K"   : @" +1000",
                     @" L"   : @" +1100",
                     @" M"   : @" +1200",
                 } retain];

    // time zones offsets
    timeZonesOffsets = [@{
                            @" EST" : @(-5*60*60),
                            @" EDT" : @(-4*60*60),
                            @" CST" : @(-6*60*60),
                            @" CDT" : @(-5*60*60),
                            @" MST" : @(-7*60*60),
                            @" MDT" : @(-6*60*60),
                            @" PST" : @(-8*60*60),
                            @" PDT" : @(-7*60*60),
                            @" Y"   : @(-12*60*60),
                            @" X"   : @(-11*60*60),
                            @" W"   : @(-10*60*60),
                            @" V"   : @(-9*60*60),
                            @" U"   : @(-8*60*60),
                            @" T"   : @(-7*60*60),
                            @" S"   : @(-6*60*60),
                            @" R"   : @(-5*60*60),
                            @" Q"   : @(-4*60*60),
                            @" P"   : @(-3*60*60),
                            @" O"   : @(-2*60*60),
                            @" N"   : @(-1*60*60),
                            @" Z"   : @(0),
                            @" A"   : @(1*60*60),
                            @" B"   : @(2*60*60),
                            @" C"   : @(3*60*60),
                            @" D"   : @(4*60*60),
                            @" E"   : @(5*60*60),
                            @" F"   : @(6*60*60),
                            @" G"   : @(7*60*60),
                            @" H"   : @(8*60*60),
                            @" I"   : @(9*60*60),
                            @" K"   : @(10*60*60),
                            @" L"   : @(11*60*60),
                            @" M"   : @(12*60*60)
                        } retain];

    return self;
}

- (NSDate *)dateFromString:(NSString *)string {
    if (string.length == 0) return nil;

    // remove weekday
    for (NSString *day in weekdays) {
        if ([string hasPrefix:day]) {
            string = [string substringFromIndex:5];
            break;
        }
    }

    // replace timezone
    for (NSString *timezone in [timezones allKeys]) {
        if ([string hasSuffix:timezone]) {
            string = [[string substringToIndex:([string length] - [timezone length])] stringByAppendingString:timezones[timezone]];
            break;
        }
    }

    NSDate *result = [dateFormatter dateFromString:string];
    if (result)
        return result;

    NSUInteger dateFormatsCount = [dateFormats count];
    for (int i = 0; i < dateFormatsCount; ++i) {
        if (i == currentFormat)
            continue;

        [dateFormatter setDateFormat:dateFormats[i]];
        result = [dateFormatter dateFromString:string];

        if (result) {
            currentFormat = i;
            return result;
        }
    }

    currentFormat = dateFormatsCount - 1;

    return nil;
}

- (NSTimeZone *)timezoneFromDateString:(NSString *)string {
    NSTimeZone *gmt = [NSTimeZone timeZoneForSecondsFromGMT:0];

    if (string.length == 0) return gmt;

    for (NSString *timezone in [timeZonesOffsets allKeys]) {
        if ([string hasSuffix:timezone]) {
            NSInteger offset = [timeZonesOffsets[timezone] integerValue];
            return [NSTimeZone timeZoneForSecondsFromGMT:offset];
        }
    }

    NSString *timeZoneStr = [string substringFromIndex:([string length] - 5)];
    int sign = 0;
    if ([timeZoneStr characterAtIndex:0] == '+')
        sign = 1;
    else if ([timeZoneStr characterAtIndex:0] == '-')
        sign = -1;
    else
        return gmt;

    NSString *hoursString = [timeZoneStr substringWithRange:NSMakeRange(1, 2)];
    NSString *minutesString = [timeZoneStr substringWithRange:NSMakeRange(3, 2)];

    NSScanner *hoursScanner = [[NSScanner alloc] initWithString:hoursString];
    NSInteger hours;
    BOOL result = [hoursScanner scanInteger:&hours];
    [hoursScanner release];
    if (!result)
        return gmt;

    NSScanner *minutesScanner = [[NSScanner alloc] initWithString:minutesString];
    NSInteger minutes;
    result = [minutesScanner scanInteger:&minutes];
    [minutesScanner release];
    if (!result)
        return gmt;

    NSInteger offset = sign * (hours * 60 *  60 + minutes * 60);

    return [NSTimeZone timeZoneForSecondsFromGMT:offset];
}

@end
