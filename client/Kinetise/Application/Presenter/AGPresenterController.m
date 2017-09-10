#import "AGPresenterController.h"
#import "AGLayoutManager.h"
#import "AGGPSLocator.h"
#import "AGApplication.h"
#import "AGPresenterDesc+Layout.h"

@implementation AGPresenterController

@synthesize presenter;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.presenter = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    // scroll insets
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsAvailable:) name:AGGPSLocationAvailableNotification object:nil];
    
    return self;
}

- (void)loadView {
    self.view = presenter;
}

#pragma mark - Layout

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // layout
    AGPresenterDesc *presenterDesc = (AGPresenterDesc *)presenter.descriptor;
    CGSize frameSize = self.view.bounds.size;
    
    [AGLAYOUTMANAGER layout:presenterDesc withSize:frameSize];
}

- (void)viewWillLayoutSubviews {
    AGPresenterDesc *presenterDesc = (AGPresenterDesc *)presenter.descriptor;
    CGSize frameSize = self.view.bounds.size;
    
    if (!CGSizeEqualToSize(prevFrameSize, frameSize) ) {
        prevFrameSize = frameSize;
        [AGLAYOUTMANAGER layout:presenterDesc withSize:frameSize];
    }
    
    [super viewWillLayoutSubviews];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [presenter loadFeeds];
}

- (void)gpsAvailable:(NSNotification *)notification {
    [presenter loadFeeds];
}

@end
