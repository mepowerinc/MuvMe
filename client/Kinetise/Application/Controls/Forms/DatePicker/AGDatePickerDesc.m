#import "AGDatePickerDesc.h"
#import "AGActionManager.h"

@implementation AGDatePickerDesc

@synthesize mode;
@synthesize minDate;
@synthesize maxDate;
@synthesize dateFormat;
@synthesize watermark;

#pragma mark - Initialization

- (void)dealloc {
    self.minDate = nil;
    self.maxDate = nil;
    self.dateFormat = nil;
    self.watermark = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    // min date
    [AGACTIONMANAGER executeVariable:minDate withSender:self];

    // max date
    [AGACTIONMANAGER executeVariable:maxDate withSender:self];

    // watermark
    [AGACTIONMANAGER executeVariable:watermark withSender:self];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGDatePickerDesc *obj = [super copyWithZone:zone];

    obj.mode = mode;
    obj.minDate = [[minDate copy] autorelease];
    obj.maxDate = [[maxDate copy] autorelease];
    obj.dateFormat = dateFormat;
    obj.watermark = [[watermark copy] autorelease];

    return obj;
}

@end
