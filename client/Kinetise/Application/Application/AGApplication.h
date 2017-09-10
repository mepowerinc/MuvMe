#import "NSObject+Singleton.h"
#import "AGApplicationDesc.h"
#import "AGScreen.h"
#import "AGOverlay.h"
#import "AGControlDesc.h"
#import "AGHistoryData.h"
#import "AGControl.h"
#import "AGNavigationController.h"
#import "AGNavigationDrawerController.h"
#import "AGToast.h"
#import "AGFeedClientProtocol.h"
#import "AGOverlayDesc.h"
#import "AGFeedProtocol.h"
#import "AGPopupController.h"

#define AGAPPLICATION [AGApplication sharedInstance]

@interface AGApplication : NSObject {
    AGNavigationDrawerController *rootController;
    AGNavigationController *navigationController;
    AGApplicationDesc *descriptor;
    AGScreen *currentScreen;
    AGScreenDesc *currentScreenDesc;
    AGOverlay *currentOverlay;
    AGOverlayDesc *currentOverlayDesc;
    AGPopupController *currentPopup;
    NSMutableArray *screenStack;
    id currentContext;
    NSString *alterApiContext;
    NSString *guidContext;
    BOOL isLoadingScreen;
    CGFloat textMultiplier;
    AGToast *toast;
    AGHistoryData *protectedScreenData;
}

SINGLETON_INTERFACE(AGApplication)

@property(nonatomic, readonly) AGNavigationDrawerController *rootController;
@property(nonatomic, readonly) AGNavigationController *navigationController;
@property(nonatomic, readonly) AGApplicationDesc *descriptor;
@property(nonatomic, readonly) AGScreen *currentScreen;
@property(nonatomic, readonly) AGScreenDesc *currentScreenDesc;
@property(nonatomic, readonly) AGOverlay *currentOverlay;
@property(nonatomic, readonly) AGOverlayDesc *currentOverlayDesc;
@property(nonatomic, readonly) AGPopupController *currentPopup;
@property(nonatomic, readonly) id currentContext;
@property(nonatomic, copy) NSString *alterApiContext;
@property(nonatomic, copy) NSString *guidContext;
@property(nonatomic, copy) NSString *sessionId;
@property(nonatomic, copy) NSString *basicAuthSessionId;
@property(nonatomic, assign) CGFloat textMultiplier;
@property(nonatomic, readonly) AGToast *toast;
@property(nonatomic, readonly) BOOL isLoggedIn;

- (UIViewController *)loadApplication:(AGApplicationDesc *)desc;

- (void)refresh;
- (void)reload;

@end
