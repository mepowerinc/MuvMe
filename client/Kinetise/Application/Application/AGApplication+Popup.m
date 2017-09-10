#import "AGApplication+Popup.h"
#import <RMUniversalAlert/RMUniversalAlert.h>
#import "AGLocalizationManager.h"
#import "AGLayoutManager.h"
#import "AGPopup.h"
#import "AGPopupController.h"
#import "AGAlertWindow.h"
#import "AGPopupDesc+Layout.h"

@implementation AGApplication (Popup)

- (void)showAlert:(NSString *)title message:(NSString *)message andCancelButton:(NSString *)cancelButton {
#ifdef DEBUG
    if (![NSThread isMainThread]) {
        NSLog(@"WARNING: Try to show popup on separate thread !!!");
    }
#endif

    AGAlertWindow *alertWindow = [[[AGAlertWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    [alertWindow makeKeyAndVisible];
    __block AGAlertWindow *weakAlertWindow = alertWindow;

    [RMUniversalAlert showAlertInViewController:alertWindow.rootViewController
                                      withTitle:title
                                        message:message
                              cancelButtonTitle:cancelButton
                         destructiveButtonTitle:nil
                              otherButtonTitles:nil
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
        weakAlertWindow.hidden = YES;
    }];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    NSString *cancelButtonTitle = [AGLOCALIZATION localizedString:@"CLOSE_POPUP"];

    [self showAlert:title message:message andCancelButton:cancelButtonTitle];
}

- (void)showInfoPopup:(NSString *)message {
    NSString *title = [AGLOCALIZATION localizedString:@"POPUP_INFO_HEADER"];
    NSString *cancelButtonTitle = [AGLOCALIZATION localizedString:@"CLOSE_POPUP"];

    [self showAlert:title message:message andCancelButton:cancelButtonTitle];
}

- (void)showErrorPopup:(NSString *)message {
    NSString *title = [AGLOCALIZATION localizedString:@"POPUP_ERROR_HEADER"];
    NSString *cancelButtonTitle = [AGLOCALIZATION localizedString:@"CLOSE_POPUP"];

    [self showAlert:title message:message andCancelButton:cancelButtonTitle];
}

- (void)showPopup:(AGControlDesc *)controlDesc {
    if (currentPopup || !controlDesc) return;

#ifdef DEBUG
    if (![NSThread isMainThread]) {
        NSLog(@"WARNING: Try to show popup on separate thread !!!");
    }
#endif

    AGPopupDesc *popupDesc = [[AGPopupDesc alloc] init];
    popupDesc.controlDesc = controlDesc;

    // execute variables
    [popupDesc executeVariables];
    
    // update
    [popupDesc update];

    // layout descriptors
    [AGLAYOUTMANAGER layout:popupDesc withSize:[UIScreen mainScreen].bounds.size];

    // current overlay
    AGPopup *popup = [[AGPopup alloc] initWithDesc:popupDesc];
    [popupDesc release];

    // popup view controller
    AGPopupController *viewController = [[AGPopupController alloc] initWithNibName:nil bundle:nil];
    viewController.presenter = popup;
    [popup release];

    // layout views
    [popup setNeedsLayout];

    // setup assets
    [popup setupAssets];

    // load assets
    [popup loadAssets];

    // show
    [viewController present:YES completion:nil];
    currentPopup = viewController;
}

- (void)hidePopup {
    [currentPopup dismiss:YES completion:^{
        currentPopup = nil;
    }];
}

@end
