#import "AGApplication+Overlay.h"
#import "AGLayoutManager.h"
#import "AGGPSLocator.h"
#import "AGOverlayController.h"
#import "AGOverlayDesc+Layout.h"
#import "AGActionManager.h"

@implementation AGApplication (Overlay)

- (void)showOverlay:(NSString *)overlayId {
    if (currentOverlay) return;

    AGOverlayDesc *overlayDesc = descriptor.overlays[overlayId];
    currentOverlayDesc = overlayDesc;

    // execute variables
    [overlayDesc executeVariables];
    
    // update
    [overlayDesc update];

    // layout descriptors
    [AGLAYOUTMANAGER layout:overlayDesc withSize:[UIScreen mainScreen].bounds.size];

    // current overlay
    currentOverlay = [[AGOverlay alloc] initWithDesc:overlayDesc];

    // permissions
    if (currentScreenDesc.permissions&AGPermissionGPS) {
        [AGGPSLocator sharedInstance];
    }

    // on enter
    if (currentOverlayDesc.onEnterAction) {
        [AGACTIONMANAGER executeAction:currentOverlayDesc.onEnterAction withSender:nil];
    }

    // overlay view controller
    AGOverlayController *viewController = [[AGOverlayController alloc] initWithNibName:nil bundle:nil];
    viewController.presenter = currentOverlay;
    [currentOverlay release];

    // layout views
    [currentOverlay setNeedsLayout];

    // setup assets
    [currentOverlay setupAssets];

    // load assets
    [currentOverlay loadAssets];

    // settings
    {
        // position
        if (overlayDesc.animation == overlayAnimationLeft) {
            AGAPPLICATION.rootController.panelPosition = drawerPanelPositionLeft;
        } else if (overlayDesc.animation == overlayAnimationRight) {
            AGAPPLICATION.rootController.panelPosition = drawerPanelPositionRight;
        } else if (overlayDesc.animation == overlayAnimationTop) {
            AGAPPLICATION.rootController.panelPosition = drawerPanelPositionTop;
        } else {
            AGAPPLICATION.rootController.panelPosition = drawerPanelPositionBottom;
        }

        // move screen
        AGAPPLICATION.rootController.shouldMoveScreen = overlayDesc.moveScreen;

        // move overlay
        AGAPPLICATION.rootController.shouldMoveOverlay = overlayDesc.moveOverlay;

        // background
        AGAPPLICATION.rootController.shouldGrayoutBackgroud = overlayDesc.grayoutBackground;
    }

    // show
    AGAPPLICATION.rootController.panelController = viewController;
    [viewController release];
    [AGAPPLICATION.rootController showPanel];

    // load feeds
    [currentOverlay loadFeeds];
}

- (void)hideOverlay {
    if (!currentOverlay) return;

    [AGAPPLICATION.rootController hidePanel];
}

#pragma mark - AGNavigationDrawerControllerDelegate

- (void)navigationDrawerWillHidePanel:(AGNavigationDrawerController *)drawer {
    // on exit
    if (currentOverlayDesc.onExitAction) {
        [AGACTIONMANAGER executeAction:currentOverlayDesc.onExitAction withSender:nil];
    }
}

- (void)navigationDrawerDidHidePanel:(AGNavigationDrawerController *)drawer {
    // clean
    currentOverlay = nil;
    currentOverlayDesc = nil;
    AGAPPLICATION.rootController.panelController = nil;
}

@end
