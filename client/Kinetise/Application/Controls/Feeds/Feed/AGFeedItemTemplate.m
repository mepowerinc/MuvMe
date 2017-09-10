#import "AGFeedItemTemplate.h"

@implementation AGFeedItemTemplate

@synthesize requiredFields;
@synthesize detailScreenId;
@synthesize controlDesc;

- (void)dealloc {
    [requiredFields release];
    self.detailScreenId = nil;
    self.controlDesc = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    requiredFields = [[NSMutableArray alloc] init];

    return self;
}

@end
