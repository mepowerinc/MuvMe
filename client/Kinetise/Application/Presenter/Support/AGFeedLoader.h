#import <Foundation/Foundation.h>
#import "AGFeedClientProtocol.h"
#import "AGScreenDesc.h"

@interface AGFeedLoader : NSObject

- (id)initWithFeeds:(NSArray *)feeds;
- (void)loadFeeds;
- (void)reloadFeeds;
- (void)loadNextFeedPage:(id<AGFeedClientProtocol>)feedClient;

@end
