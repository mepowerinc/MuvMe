#import "AGAdapterLayout.h"

@implementation AGAdapterLayout

@synthesize descriptor;

- (void)dealloc {
    self.descriptor = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGControlDesc<AGFeedClientProtocol> *)descriptor_ {
    self = [super init];

    self.descriptor = descriptor_;

    return self;
}

@end
