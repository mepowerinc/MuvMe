#import "AGContainerDesc.h"
#import "AGFeedClientProtocol.h"

@interface AGDataFeedDesc : AGContainerDesc <AGFeedClientProtocol>{
    AGFeed *feed;
}

@end
