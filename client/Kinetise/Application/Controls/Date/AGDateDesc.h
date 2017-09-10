#import "AGTextDesc.h"
#import "AGDateFormatter.h"

@interface AGDateDesc : AGTextDesc {
    NSString *dateFormat;
    BOOL ticking;
    AGDateSource dateSrc;
    AGDateTimezone timezone;
    AGDateFormatter *dateFormatter;
}

@property(nonatomic, copy) NSString *dateFormat;
@property(nonatomic, assign) BOOL ticking;
@property(nonatomic, assign) AGDateSource dateSrc;
@property(nonatomic, assign) AGDateTimezone timezone;
@property(nonatomic, retain) AGDateFormatter *dateFormatter;

@end
