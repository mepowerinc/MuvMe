#import <AVFoundation/AVFoundation.h>
#import "AGPresenter.h"
#import "AGScreenDesc.h"
#import "AGBody.h"
#import "AGHeader.h"
#import "AGNaviPanel.h"
#import "AGImageAsset.h"
#import "AGImageView.h"

@interface AGScreen : AGPresenter <AGAssetDelegate>{
    AVPlayer *backgroundVideoPlayer;
    AVPlayerLayer *backgroundVideoPlayerLayer;
    UIImageView *backgroundVideoView;
    AGImageView *backgroundView;
    AGBody *body;
    AGHeader *header;
    AGNaviPanel *naviPanel;
    AGImageAsset *backgroundSource;
    AGPullToRefresh *pullToRefresh;
    BOOL shouldRoundCalculates;
}

@property(nonatomic, readonly) AGHeader *header;
@property(nonatomic, readonly) AGBody *body;
@property(nonatomic, readonly) AGNaviPanel *naviPanel;

- (void)reloadHeaderAndNaviPanel;
- (void)delayAction:(NSString *)action withTimeout:(NSInteger)timeout;

@end
