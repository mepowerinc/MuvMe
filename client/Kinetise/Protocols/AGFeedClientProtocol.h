#import "AGFeed.h"

@protocol AGFeedClientProtocol <NSObject>

@property(nonatomic, retain) AGFeed *feed;

- (void)removeFeedControls;
- (void)removeLastFeedControl;
- (void)addFeedControl:(AGControlDesc *)controlDesc;
- (NSArray *)feedControls;

@end
