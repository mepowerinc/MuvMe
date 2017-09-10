#import "AGBodyDesc.h"

@implementation AGBodyDesc

@synthesize verticalScrollOffset;

- (id)init {
    self = [super init];

    // vertical scroll
    hasVerticalScroll = YES;

    return self;
}

#pragma mark - State

- (void)resetState {
    [super resetState];

    verticalScrollOffset = 0;
}

@end
