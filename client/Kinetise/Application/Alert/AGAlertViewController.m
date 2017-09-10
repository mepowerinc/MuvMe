#import "AGAlertViewController.h"
#import "AGApplication.h"

@implementation AGAlertViewController

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([AGApplication isAllocated]) {
        return [AGAPPLICATION.rootController supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    if ([AGApplication isAllocated]) {
        return [AGAPPLICATION.rootController shouldAutorotate];
    }
    
    return YES;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([AGApplication isAllocated]) {
        return [AGAPPLICATION.rootController preferredStatusBarStyle];
    }
    
    return UIStatusBarStyleLightContent;
}

@end
