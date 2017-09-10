#import "AGFeedClientProtocol.h"
#import "AGAsset.h"

@interface AGFeedRequest : NSObject

@property(nonatomic, retain) AGControlDesc<AGFeedClientProtocol> *feedClient;
@property(nonatomic, retain) AGAsset *source;
@property(nonatomic, assign) BOOL isReload;
@property(nonatomic, assign) BOOL isLoadMore;

- (id)initWithFeedClient:(AGControlDesc<AGFeedClientProtocol> *)feedClient;

@end
