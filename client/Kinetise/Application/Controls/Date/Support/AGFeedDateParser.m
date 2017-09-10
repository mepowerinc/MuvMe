#import "AGFeedDateParser.h"
#import "AGRFC822DateParser.h"
#import "AGRFC3339DateParser.h"

@interface AGFeedDateParser (){
    AGDateParser *currentDateParser;
    AGRFC822DateParser *rfc822DateParser;
    AGRFC3339DateParser *rfc3339DateParser;
}
@end

@implementation AGFeedDateParser

- (void)dealloc {
    [rfc822DateParser release];
    [rfc3339DateParser release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // date parsers
    rfc822DateParser = [[AGRFC822DateParser alloc] init];
    rfc3339DateParser = [[AGRFC3339DateParser alloc] init];
    currentDateParser = rfc822DateParser;

    return self;
}

- (NSDate *)dateFromString:(NSString *)string {
    NSDate *date = [currentDateParser dateFromString:string];

    if (!date) {
        if (currentDateParser == rfc822DateParser) {
            currentDateParser = rfc3339DateParser;
        } else {
            currentDateParser = rfc822DateParser;
        }
        date = [currentDateParser dateFromString:string];
    }

    return date;
}

- (NSTimeZone *)timezoneFromDateString:(NSString *)string {
    NSTimeZone *timeZone = [currentDateParser timezoneFromDateString:string];

    if (!timeZone) {
        if (currentDateParser == rfc822DateParser) {
            currentDateParser = rfc3339DateParser;
        } else {
            currentDateParser = rfc822DateParser;
        }
        timeZone = [currentDateParser timezoneFromDateString:string];
    }

    return timeZone;
}

@end
