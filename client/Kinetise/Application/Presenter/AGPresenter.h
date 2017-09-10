#import "AGView.h"
#import "AGPresenterDesc.h"
#import "AGFeedLoader.h"

@interface AGPresenter : AGView <UIGestureRecognizerDelegate>{
    AGFeedLoader *feedLoader;
    UITapGestureRecognizer *bcgTapGestureRecognizer;
}

- (void)refresh;
- (void)reload;
- (void)loadFeeds;
- (void)reloadFeeds;
- (void)loadNextFeedPage:(id<AGFeedClientProtocol>)feedClient;

@end
