#import "AGAsset.h"
#import "AGFeed.h"
#import "AGFeedParseOperation.h"

@interface AGFeedAsset : AGAsset <AGFeedParseOperationDelegate>{
    AGFeedParseOperation *feedOperation;
    AGFeed *feed;
}

@property(nonatomic, retain) AGFeed *feed;

@end
