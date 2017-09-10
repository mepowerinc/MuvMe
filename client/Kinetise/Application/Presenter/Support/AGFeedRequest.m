#import "AGFeedRequest.h"

@implementation AGFeedRequest

@synthesize feedClient;
@synthesize source;
@synthesize isReload;
@synthesize isLoadMore;

#pragma mark - Intialization

- (void)dealloc {
    [source clearDelegatesAndCancel];
    self.source = nil;
    self.feedClient = nil;
    [super dealloc];
}

- (id)initWithFeedClient:(AGControlDesc<AGFeedClientProtocol> *)feedClient_ {
    self = [super init];

    self.feedClient = feedClient_;

    return self;
}

@end
