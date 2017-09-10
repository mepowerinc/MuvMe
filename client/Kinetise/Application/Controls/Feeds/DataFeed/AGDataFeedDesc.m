#import "AGDataFeedDesc.h"
#import "AGActionManager.h"

@implementation AGDataFeedDesc

@synthesize feed;

#pragma mark - Initialization

- (void)dealloc {
    self.feed = nil;
    [super dealloc];
}

#pragma mark - State

- (void)resetState {
    [super resetState];

    self.feed.pageIndex = 0;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    [feed executeVariables:self];
}

#pragma mark - Feed

- (void)removeFeedControls {
    [children removeAllObjects];
}

- (void)removeLastFeedControl {
    [children removeLastObject];
}

- (void)addFeedControl:(AGControlDesc *)controlDesc {
    [self addChild:controlDesc];
}

- (NSArray *)feedControls {
    return children;
}

@end
