#import "AGNavigationController.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "AGApplication+Popup.h"

@implementation AGNavigationController

@synthesize transition;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    // navigation bar
    [self setNavigationBarHidden:YES animated:NO];
    
    return self;
}

#pragma mark - Lifecycle

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    
    [AGAPPLICATION hidePopup];
}

- (void)presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)moviePlayerViewController {
    [super presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    
    [AGAPPLICATION hidePopup];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([self.visibleViewController isKindOfClass:[UIAlertController class]]) {
        return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    }
    
    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

@end
