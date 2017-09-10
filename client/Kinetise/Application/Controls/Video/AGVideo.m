#import "AGVideo.h"
#import "AGVideoDesc.h"
#import "AGApplication.h"
#import "NSString+UriEncoding.h"

@implementation AGVideo

- (void)dealloc {
    [playerController.player pause];
    [playerController release];
    [super dealloc];
}

- (id)initWithDesc:(AGVideoDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // player
    AVPlayer *player = [[AVPlayer alloc] init];
    playerController = [[AVPlayerViewController alloc] init];
    playerController.player = player;
    [player release];
    [contentView addSubview:playerController.view];

    // audio ignore mute switch
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    playerController.view.frame = contentView.bounds;
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    AGVideoDesc *desc = (AGVideoDesc *)descriptor;

    // url
    NSString *uri = [desc.src.value uriString];
    NSURL *url = [NSURL URLWithString:uri];

    [self setUrl:url];
}

- (void)setUrl:(NSURL *)url {
    AGVideoDesc *desc = (AGVideoDesc *)descriptor;

    AVURLAsset *asset = (AVURLAsset *)playerController.player.currentItem.asset;

    // player url
    if (![url isEqual:asset.URL]) {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
        [playerController.player replaceCurrentItemWithPlayerItem:item];
        [item release];
    }

    // autoplay
    if (desc.autoplay) {
        [playerController.player play];
    }
}

@end
