#import "AGScreen.h"
#import "UIView+Debug.h"
#import "AGApplication.h"
#import "AGApplication+Navigation.h"
#import "AGApplication+Control.h"
#import "AGApplication+Popup.h"
#import "AGImageCache.h"
#import "NSObject+Nil.h"
#import "UIView+FirstResponder.h"
#import "AGScrollView.h"
#import "AGLayoutManager.h"
#import "AGReachability.h"
#import "AGScreenDesc+Layout.h"
#import "AGFileManager.h"
#import "AGActionManager.h"

@implementation AGScreen

@synthesize header;
@synthesize body;
@synthesize naviPanel;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [backgroundSource clearDelegatesAndCancel];
    [backgroundSource release];
    [super dealloc];
}

- (id)initWithDesc:(AGScreenDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // background color
    self.backgroundColor = [UIColor colorWithRed:descriptor_.backgroundColor.r green:descriptor_.backgroundColor.g blue:descriptor_.backgroundColor.b alpha:descriptor_.backgroundColor.a];

    // background
    if (descriptor_.background) {
        backgroundView = [[AGImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:backgroundView];
        [backgroundView release];
    }

    // background size mode
    if (descriptor_.backgroundSizeMode == sizeModeStretch) {
        backgroundView.contentMode = UIViewContentModeScaleToFill;
    } else if (descriptor_.backgroundSizeMode == sizeModeShortedge) {
        backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (descriptor_.backgroundSizeMode == sizeModeLongedge) {
        backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    }

    // background video
    if (descriptor_.backgroundVideo) {
        backgroundVideoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:backgroundVideoView];
        [backgroundVideoView release];

        // url
        NSString *uri = descriptor_.backgroundVideo.value;
        NSURL *url = nil;

        if ([uri hasPrefix:@"assets://"]) {
            NSString *fileName = [uri substringFromIndex:[@"assets://" length] ];
            NSString *filePath = [AGFILEMANAGER pathForResource:fileName];
            url = [NSURL fileURLWithPath:filePath];
        } else if ([uri hasPrefix:@"http"]) {
            url = [NSURL URLWithString:uri];
        }
        //url = [NSURL URLWithString:@"http://cdn.clipcanvas.com/sample/clipcanvas_14348_offline.mp4"];

        // asset
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];

        // video preview
        if ([uri hasPrefix:@"assets://"]) {
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generator.appliesPreferredTrackTransform = YES;

            CGImageRef imgRef = [generator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
            UIImage *image = [[UIImage alloc] initWithCGImage:imgRef];
            if (image) {
                backgroundVideoView.image = image;
                backgroundVideoView.contentMode = UIViewContentModeScaleAspectFill;
            }
            [image release];
            CGImageRelease(imgRef);
            [generator release];
        }

        // player
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        [asset release];
        backgroundVideoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [playerItem release];
        backgroundVideoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:backgroundVideoPlayer];
        [backgroundVideoPlayer release];
        [backgroundVideoView.layer addSublayer:backgroundVideoPlayerLayer];
        backgroundVideoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [backgroundVideoPlayer seekToTime:kCMTimeZero];
        [backgroundVideoPlayer play];

        // infinity loop
        backgroundVideoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;

        // observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }

    // body
    if (descriptor_.body) {
        body = [[AGBody alloc] initWithDesc:descriptor_.body];
        [self addSubview:body];
        [body release];
    }

    // header
    if (descriptor_.header) {
        header = [[AGHeader alloc] initWithDesc:descriptor_.header];
        [self addSubview:header];
        [header release];
    }

    // navipanel
    if (descriptor_.naviPanel) {
        naviPanel = [[AGNaviPanel alloc] initWithDesc:descriptor_.naviPanel];
        [self addSubview:naviPanel];
        [naviPanel release];
    }

    // background source
    if (descriptor_.background) {
        backgroundSource = [[AGImageAsset alloc] initWithUri:[descriptor_.background.value uriString] ];
        backgroundSource.delegate = self;
    }

    // pull to refresh
    if (descriptor_.hasPullToRefresh) {
        AGScrollView *scrollView = (AGScrollView *)body.contentView;
        scrollView.alwaysBounceVertical = YES;

        pullToRefresh = [[AGPullToRefresh alloc] initWithFrame:CGRectZero];
        [scrollView addSubview:pullToRefresh];
        [pullToRefresh release];
        [pullToRefresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    }

    return self;
}

#pragma mark - Lifecycle

- (void)reloadHeaderAndNaviPanel {
    // execute variables
    [header.descriptor executeVariables];
    [naviPanel.descriptor executeVariables];
    
    // update
    [header.descriptor update];
    [naviPanel.descriptor update];
    
    // layout descriptors
    [AGLAYOUTMANAGER layout:(id < AGLayoutProtocol >)header.descriptor];
    [AGLAYOUTMANAGER layout:(id < AGLayoutProtocol >)naviPanel.descriptor];
    
    // layout views
    [header setNeedsLayout];
    [naviPanel setNeedsLayout];
    
    // setup assets
    [header setupAssets];
    [naviPanel setupAssets];
    
    // load assets
    [header loadAssets];
    [naviPanel loadAssets];
    
    // force layout
    [header layoutIfNeeded];
    [naviPanel layoutIfNeeded];
}

- (void)delayAction:(NSString *)action withTimeout:(NSInteger)timeout {
    [self performSelector:@selector(executeAction:) withObject:action afterDelay:timeout*0.001f inModes:@[NSRunLoopCommonModes]];
}

- (void)executeAction:(NSString *)action {
    [AGACTIONMANAGER executeString:action withSender:nil];
}

- (void)onRefresh:(AGPullToRefresh *)refresh {
    [feedLoader reloadFeeds];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];

    if (!newSuperview) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    AGScreenDesc *desc = (AGScreenDesc *)descriptor;

    backgroundSource.prefferedImageSize = MAX(desc.width, desc.height);

    [header setupAssets];
    [body setupAssets];
    [naviPanel setupAssets];
}

- (void)loadAssets {
    [super loadAssets];

    [backgroundSource execute];

    [header loadAssets];
    [body loadAssets];
    [naviPanel loadAssets];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    // header
    AGHeaderDesc *headerDesc = (AGHeaderDesc *)header.descriptor;
    header.frame = CGRectMake(headerDesc.positionX,
                              headerDesc.positionY,
                              headerDesc.width,
                              headerDesc.height);
    [header setNeedsLayout];

    // navipanel
    AGNaviPanelDesc *naviPanelDesc = (AGNaviPanelDesc *)naviPanel.descriptor;
    naviPanel.frame = CGRectMake(naviPanelDesc.positionX,
                                 naviPanelDesc.positionY,
                                 naviPanelDesc.width,
                                 naviPanelDesc.height);
    [naviPanel setNeedsLayout];

    // body
    AGBodyDesc *bodyDesc = (AGBodyDesc *)body.descriptor;
    body.frame = CGRectMake(bodyDesc.positionX,
                            bodyDesc.positionY,
                            bodyDesc.width,
                            bodyDesc.height);
    [body setNeedsLayout];

    // background
    backgroundView.frame = self.bounds;

    // background video
    backgroundVideoView.frame = self.bounds;
    backgroundVideoPlayerLayer.frame = self.bounds;

    // pull to refresh
    CGFloat refreshInset = SCREEN_LONGER_SIDE*0.1f;
    pullToRefresh.frame = CGRectMake(0, -refreshInset, SCREEN_WIDTH, refreshInset);
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    if (asset_ == backgroundSource && asset_.assetType != assetFile) {
        backgroundView.image = nil;
    }
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    if (asset_ == backgroundSource) {
        backgroundView.image = object;
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    if (asset_ == backgroundSource) {
        backgroundView.image = AG_ERROR_IMAGE;
    }
}

#pragma mark - Notifications

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [backgroundVideoPlayer pause];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [backgroundVideoPlayer play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [backgroundVideoPlayer seekToTime:kCMTimeZero];
}

@end
