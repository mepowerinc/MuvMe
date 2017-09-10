#import "AGApplication.h"
#import <FXKeychain/FXKeychain.h>
#import "AGLayoutManager.h"
#import "AGActionManager.h"
#import "AGContainerDesc.h"
#import "AGImageCache.h"
#import "AGContainer.h"
#import "AGTextMeasurer.h"
#import "AGGPSLocator.h"
#import "AGReachability.h"
#import "NSObject+Nil.h"
#import "AGScreenDesc+Layout.h"
#import "AGSocialManager.h"
#import "AGFormClientProtocol.h"
#import "AGCheckBoxDesc.h"
#import "AGRadioButtonDesc.h"
#import "AGToast.h"
#import "AGServicesManager.h"
#import "AGApplication+Navigation.h"
#import "AGApplication+Overlay.h"
#import "AGSynchronizer.h"
#import "AGOverlayDesc+Layout.h"
#import "AGLocalizationManager.h"
#import "AGSplashController.h"
#import "AGFileManager.h"
#import "AGLocalStorage.h"
#import "UIApplication+Launch.h"
#import "AGGPSTracker.h"

#define KEY_IS_LOGGED_IN @"is_logged_in"
#define KEY_SESSIONID @"session_id"
#define KEY_BASICAUTH_SESSIONID @"basicauth_session_id"
#define KEY_TEXT_MULTIPLIER @"text_multiplier"

@interface AGApplication () <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>
@property(nonatomic, retain) AGHistoryData *protectedScreenData;
@property(nonatomic, retain) id currentContext;
@property(nonatomic, assign) BOOL isLoggedIn;
@property(nonatomic, assign) BOOL prevReachability;
@end

@implementation AGApplication

SINGLETON_IMPLEMENTATION(AGApplication)

@synthesize rootController;
@synthesize navigationController;
@synthesize descriptor;
@synthesize currentScreen;
@synthesize currentScreenDesc;
@synthesize currentOverlay;
@synthesize currentOverlayDesc;
@synthesize currentPopup;
@synthesize currentContext;
@synthesize alterApiContext;
@synthesize guidContext;
@synthesize sessionId;
@synthesize basicAuthSessionId;
@synthesize textMultiplier;
@synthesize toast;
@synthesize protectedScreenData;
@synthesize isLoggedIn;
@synthesize prevReachability;

#pragma mark - Initialization

- (void)dealloc {
    [AGGPSLocator end];
    [AGReachability end];
    [AGSocialManager end];
    [AGImageCache end];
    [AGTextMeasurer end];
    [AGLayoutManager end];
    [AGActionManager end];
    [AGSynchronizer end];
    [AGLocalizationManager end];
    [AGLocalStorage end];
    
    [rootController release];
    [descriptor release];
    [currentScreen release];
    [screenStack release];
    [toast release];
    
    self.currentContext = nil;
    self.alterApiContext = nil;
    self.guidContext = nil;
    self.protectedScreenData = nil;
    
    [sessionId release];
    sessionId = nil;
    [basicAuthSessionId release];
    basicAuthSessionId = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    // reachability
    prevReachability = ([Reachability reachabilityForInternetConnection].currentReachabilityStatus != NotReachable);
    
    // reset or read data
    if ([[UIApplication sharedApplication] isFirstLaunch]) {
        self.isLoggedIn = NO;
        self.sessionId = nil;
        self.basicAuthSessionId = nil;
    } else {
        self.isLoggedIn = [[[FXKeychain defaultKeychain] objectForKey:KEY_IS_LOGGED_IN] boolValue];
        self.sessionId = [[FXKeychain defaultKeychain] objectForKey:KEY_SESSIONID];
        self.basicAuthSessionId = [[FXKeychain defaultKeychain] objectForKey:KEY_BASICAUTH_SESSIONID];
    }
    
    // text multiplier
    if (![[NSUserDefaults standardUserDefaults] objectForKey:KEY_TEXT_MULTIPLIER]) {
        textMultiplier = 1.0f;
        [[NSUserDefaults standardUserDefaults] setFloat:textMultiplier forKey:KEY_TEXT_MULTIPLIER];
    } else {
        textMultiplier = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_TEXT_MULTIPLIER];
    }
    
    // preload
    AG_ERROR_IMAGE;
    AG_LOADING_IMAGE;
    
    // root controller
    rootController = [[AGNavigationDrawerController alloc] init];
    rootController.delegate = self;
    
    // navigation controller
    navigationController = [[AGNavigationController alloc] init];
    navigationController.delegate = self;
    rootController.mainController = navigationController;
    [navigationController release];
    
    // stack
    screenStack = [[NSMutableArray alloc] init];
    
    return self;
}

#pragma mark - Lifecycle

- (UIViewController *)loadApplication:(AGApplicationDesc *)desc {
    [descriptor release];
    descriptor = [desc retain];
    
    // init singletons
    [AGReachability sharedInstance];
    [AGImageCache sharedInstance];
    [AGTextMeasurer sharedInstance];
    [AGLayoutManager sharedInstance];
    [AGActionManager sharedInstance];
    [AGSynchronizer sharedInstance];
    [AGLocalizationManager sharedInstance];
    [AGLocalStorage sharedInstance];
    
    // social
    if (desc.permissions&AGPermissionFacebook) {
        [AGSocialManager sharedInstance];
        [AGSocialManager sharedInstance].services |= AGSocialServiceFacebook;
    }
    if (desc.permissions&AGPermissionTwitter) {
        [AGSocialManager sharedInstance];
        [AGSocialManager sharedInstance].services |= AGSocialServiceTwitter;
    }
    
    // gps tracking
    if (desc.permissions&AGPermissionGPSTracking) {
        [AGGPSTracker sharedInstance];
    }
    
    // start screen
    [AGACTIONMANAGER executeVariable:descriptor.startScreen withSender:nil];
    [AGACTIONMANAGER executeVariable:descriptor.loginScreen withSender:nil];
    [AGACTIONMANAGER executeVariable:descriptor.protectedLoginScreen withSender:nil];
    [AGACTIONMANAGER executeVariable:descriptor.mainScreen withSender:nil];
    
    // find start screen
    if (self.isLoggedIn) {
        [self goToScreen:descriptor.mainScreen.value ];
    } else {
        [self goToScreen:descriptor.startScreen.value ];
    }
    
    // toast
    toast = [[AGToast alloc] init];
    
    // notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    return rootController;
}

- (void)refresh {
    [currentScreen refresh];
    [currentOverlay refresh];
}

- (void)reload {
    [currentScreen reload];
    [currentOverlay reload];
}

- (void)setTextMultiplier:(CGFloat)textMultiplier_ {
    if (textMultiplier_ == textMultiplier) return;
    
    textMultiplier = textMultiplier_;
    
    [[NSUserDefaults standardUserDefaults] setFloat:textMultiplier_ forKey:KEY_TEXT_MULTIPLIER];
    
    // refresh screen
    [AGAPPLICATION refresh];
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn_ {
    isLoggedIn = isLoggedIn_;
    
    if (isLoggedIn_) {
        [[FXKeychain defaultKeychain] setObject:@(isLoggedIn) forKey:KEY_IS_LOGGED_IN];
    } else {
        [[FXKeychain defaultKeychain] removeObjectForKey:KEY_IS_LOGGED_IN];
    }
    
    NSLog(@"isLoggedIn: %d", isLoggedIn);
}

- (void)setSessionId:(NSString *)sessionId_ {
    [sessionId release];
    sessionId = [sessionId_ copy];
    
    if (sessionId_) {
        [[FXKeychain defaultKeychain] setObject:sessionId_ forKey:KEY_SESSIONID];
    } else {
        [[FXKeychain defaultKeychain] removeObjectForKey:KEY_SESSIONID];
    }
    
    NSLog(@"sessionId: %@", sessionId_);
}

- (void)setBasicAuthSessionId:(NSString *)basicAuthSessionId_ {
    [basicAuthSessionId release];
    basicAuthSessionId = [basicAuthSessionId_ copy];
    
    if (basicAuthSessionId_) {
        [[FXKeychain defaultKeychain] setObject:basicAuthSessionId_ forKey:KEY_BASICAUTH_SESSIONID];
    } else {
        [[FXKeychain defaultKeychain] removeObjectForKey:KEY_BASICAUTH_SESSIONID];
    }
    
    NSLog(@"Basic auth sessionId: %@", basicAuthSessionId_);
}

#pragma mark - Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // toast
    if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable)) {
        [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"LOST_INTERNET_CONNECTION"] ];
    }
}

- (void)changeNetworkStatus:(NSNotification *)notification {
    Reachability *reachability = [notification object];
    
    // toast
    if (prevReachability && reachability.currentReachabilityStatus == NotReachable) {
        [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"LOST_INTERNET_CONNECTION"] ];
    }
    if (!prevReachability && reachability.currentReachabilityStatus != NotReachable) {
        [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"INTERNET_CONNECTION_RECOVERED"] ];
    }
    
    prevReachability = (reachability.currentReachabilityStatus != NotReachable);
}

#pragma mark - Transitions

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CGRect fromViewStartFrame = containerView.bounds;
    CGRect fromViewEndFrame = containerView.bounds;
    CGRect toViewStartFrame = containerView.bounds;
    CGRect toViewEndFrame = containerView.bounds;
    
    // frames
    if (navigationController.transition == transitionSlideLeft) {
        fromViewEndFrame = CGRectMake(-CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewStartFrame = CGRectMake(CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewEndFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionSlideRight) {
        fromViewEndFrame = CGRectMake(CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewStartFrame = CGRectMake(-CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewEndFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionCoverLeft) {
        toViewStartFrame = CGRectMake(-CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewEndFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionUncoverLeft) {
        fromViewEndFrame = CGRectMake(-CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewStartFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionCoverRight) {
        toViewStartFrame = CGRectMake(CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewEndFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionUncoverRight) {
        fromViewEndFrame = CGRectMake(CGRectGetWidth(containerView.bounds), 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewStartFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionCoverTop) {
        toViewStartFrame = CGRectMake(0, -CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewEndFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionUncoverTop) {
        fromViewEndFrame = CGRectMake(0, -CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewStartFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionCoverBottom) {
        toViewStartFrame = CGRectMake(0, CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewEndFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    } else if (navigationController.transition == transitionUncoverBottom) {
        fromViewEndFrame = CGRectMake(0, CGRectGetHeight(containerView.bounds), CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
        toViewStartFrame = CGRectMake(0, 0, CGRectGetWidth(containerView.bounds), CGRectGetHeight(containerView.bounds));
    }
    
    // animation
    fromView.frame = fromViewStartFrame;
    toView.frame = toViewStartFrame;
    [containerView addSubview:toView];
    
    if (navigationController.transition == transitionFade) {
        toView.alpha = 0.0f;
    } else if (navigationController.transition == transitionUncoverLeft || navigationController.transition == transitionUncoverRight || navigationController.transition == transitionUncoverTop || navigationController.transition == transitionUncoverBottom) {
        [containerView bringSubviewToFront:fromView];
    }
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         fromView.frame = fromViewEndFrame;
                         toView.frame = toViewEndFrame;
                         
                         if (navigationController.transition == transitionFade) {
                             toView.alpha = 1.0f;
                         }
                     }
                     completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                     }];
}

- (NSTimeInterval)transitionDuration:(id)transitionContext {
    return 0.25f;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return self;
}

@end
