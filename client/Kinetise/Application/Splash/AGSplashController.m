#import "AGSplashController.h"
#import "AGSocialManager.h"
#import "AGReachability.h"
#import "AGApplication.h"
#import "AGAnalytics.h"
#import "AGParser.h"
#import "AGFileManager.h"
#ifndef DEBUG
#import "NSObject+Debug.h"
#endif

@implementation AGSplashController

- (void)loadView {
    NSString *fileName = @"Default.png";
    
    if([UIScreen mainScreen].bounds.size.height == 480){
        fileName = @"Default@2x.png";
    } else if([UIScreen mainScreen].bounds.size.height == 568){
        fileName = @"Default-568h@2x.png";
    } else if([UIScreen mainScreen].bounds.size.height == 667){
        fileName = @"Default-667h@2x.png";
    } else if([UIScreen mainScreen].bounds.size.height == 736){
        fileName = @"Default-736h@3x.png";
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [image release];
    self.view = imageView;
    [imageView release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startApplication) withObject:nil afterDelay:0];
}

- (void)startApplication {
#ifndef DEBUG
    SEC_IS_BEING_DEBUGGED_RETURN_NIL();
#endif
    
    // application descriptor
    AGApplicationDesc *applicationDesc = [AGParser parse: [[AGFileManager sharedInstance] pathForUnlocalizedResource:@"project.xml"] ];
    
    // social
    if (applicationDesc.permissions&AGPermissionFacebook) {
        [AGSocialManager sharedInstance];
        [AGSocialManager sharedInstance].services |= AGSocialServiceFacebook;
    }
    if (applicationDesc.permissions&AGPermissionTwitter) {
        [AGSocialManager sharedInstance];
        [AGSocialManager sharedInstance].services |= AGSocialServiceTwitter;
    }
    if ([AGSocialManager isAllocated] && [AGReachability sharedInstance].reachability.currentReachabilityStatus != NotReachable) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [[AGSocialManager sharedInstance] getAccessTokens:^{
            dispatch_semaphore_signal(semaphore);
        }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    // analytics
    [[AGAnalytics sharedInstance] trackApplicationStart:applicationDesc.name];
    
    // register push notifications
    if (applicationDesc.permissions&AGPermissionPush) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }

    // start
    self.view.window.rootViewController = [[AGApplication sharedInstance] loadApplication:applicationDesc];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
