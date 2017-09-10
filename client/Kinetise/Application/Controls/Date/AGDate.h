#import "AGText.h"

@interface AGDate : AGText {
    NSDate *date;
    NSTimeZone *timeZone;
    NSTimeInterval updateTimestamp;
}

@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSTimeZone *timeZone;

- (NSDate *)dateFromSource;

@end
