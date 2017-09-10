#import "AGDateDesc.h"

@implementation AGDateDesc

@synthesize dateFormat;
@synthesize ticking;
@synthesize dateSrc;
@synthesize timezone;
@synthesize dateFormatter;

- (void)dealloc {
    self.dateFormat = nil;
    self.dateFormatter = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.dateFormatter = [[[AGDateFormatter alloc] init] autorelease];

    return self;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGDateDesc *obj = [super copyWithZone:zone];

    obj.dateFormatter = [[[AGDateFormatter alloc] init] autorelease];
    obj.dateFormat = dateFormat;
    obj.ticking = ticking;
    obj.dateSrc = dateSrc;
    obj.timezone = timezone;

    return obj;
}

@end
