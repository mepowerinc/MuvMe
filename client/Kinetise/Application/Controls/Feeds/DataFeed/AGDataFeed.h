#import "AGContainer.h"
#import "AGDataFeedAdapter.h"
#import "AGFeedProtocol.h"

@interface AGDataFeed : AGContainer <AGFeedProtocol>{
    AGDataFeedAdapter *adapter;
}

@end
