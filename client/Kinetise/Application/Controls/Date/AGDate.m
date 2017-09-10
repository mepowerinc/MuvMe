#import "AGDate.h"
#import "AGDateDesc.h"
#import "AGFeedDateParser.h"
#import "AGSntpClient.h"
#import "NSObject+Nil.h"
#import "AGLocalizationManager.h"

@interface AGDate () <FAMSntpClientDelegate>{
    AGSntpClient *sntp;
    AGFeedDateParser *dateParser;
    int attempts;
}
@end

@implementation AGDate

@synthesize date;
@synthesize timeZone;

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [dateParser release];
    sntp.delegate = nil;
    [sntp release];
    self.date = nil;
    self.timeZone = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGDateDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // date parser
    dateParser = [[AGFeedDateParser alloc] init];

    // sntp
    sntp = [[AGSntpClient alloc] init];
    sntp.delegate = self;

    // update
    [self update];

    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGDateDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }

    // update
    [self update];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    // update
    [self update];
}

#pragma mark - Assets

- (void)loadAssets {
    [super loadAssets];

    // date
    self.date = [self dateFromSource];

    // timezone
    self.timeZone = [self timezoneFromSource];

    // update timestamp
    updateTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];

    // update
    [self update];
}

#pragma mark - Update

- (void)update {
    AGDateDesc *desc = (AGDateDesc *)descriptor;

    if (desc.ticking) {
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSinceReferenceDate];
        NSTimeInterval deltaTime = timestamp - updateTimestamp;
        self.date = [date dateByAddingTimeInterval:deltaTime];
        updateTimestamp = timestamp;

        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(update) withObject:nil afterDelay:1.0f inModes:@[NSRunLoopCommonModes] ];
    }

    // label
    desc.string.string = [self text];
    label.string = desc.string;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];

    if (isNotNil(newSuperview) ) {
        AGDateDesc *desc = (AGDateDesc *)self.descriptor;
        if (desc.ticking) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(update) withObject:nil afterDelay:1.0f inModes:@[NSRunLoopCommonModes] ];
        }
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

#pragma mark - Time operations

- (NSDate *)dateFromSource {
    AGDateDesc *desc = (AGDateDesc *)self.descriptor;

    switch (desc.dateSrc) {
    case dateLocal:
        return [NSDate date];
    case dateInternet:
        if (sntp.synchronized) {
            return [sntp synchronizedTime];
        } else if (sntp.isSynchronizing) {
            return [NSDate date];
        } else if (attempts < 3) {
            ++attempts;
            NSString *timeServer = [AGLOCALIZATION localizedString:@"TIMESERVER"];
            [sntp requestTime:timeServer];
            return [NSDate date];
        } else {
            return [NSDate date];
        }
        return nil;
    case dateNode:
    {
        NSString *dateString = desc.text.value;
        return [dateParser dateFromString:dateString];
    }
    }
}

- (NSTimeZone *)timezoneFromSource {
    AGDateDesc *desc = (AGDateDesc *)self.descriptor;

    if (desc.timezone != timezoneInput || desc.dateSrc != dateNode) return nil;

    NSString *dateString = desc.text.value;
    NSTimeZone *newTimeZone = [dateParser timezoneFromDateString:dateString];

    if (!newTimeZone) {
        newTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }

    return newTimeZone;
}

- (NSString *)text {
    AGDateDesc *desc = (AGDateDesc *)self.descriptor;

    // date formatter
    desc.dateFormatter.dateFormat = desc.dateFormat;
    NSDateFormatter *dateFormatter = [desc.dateFormatter dateFormatter];

    // timezone
    if (desc.timezone == timezoneInput && desc.dateSrc == dateNode) {
        dateFormatter.timeZone = timeZone;
    }

    // invalid date
    NSString *dateStr = [dateFormatter stringFromDate:date];
    if (!dateStr) {
        dateStr = [AGLOCALIZATION localizedString:@"INVALID_DATE_FORMAT"];
    }

    return dateStr;
}

#pragma mark - FAMSntpClientDelegate

- (void)sntpClient:(AGSntpClient *)client failedWithError:(NSError *)error {
    ++attempts;
    if (attempts < 3) {
        NSString *timeServer = [AGLOCALIZATION localizedString:@"TIMESERVER"];
        [sntp requestTime:timeServer];
    }

    // update
    [self update];
}

- (void)sntpClient:(AGSntpClient *)client receivedNtpTime:(NSDate *)date_ {
    // date
    self.date = date_;

    // timezone
    self.timeZone = [self timezoneFromSource];

    // update timestamp
    updateTimestamp = [[NSDate date] timeIntervalSinceReferenceDate];

    // update
    [self update];
}

@end
