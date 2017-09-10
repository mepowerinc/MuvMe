#import "AGActionManager.h"

@interface AGActionManager (Navigation)

- (void)goToScreen:(id)sender :(id)object :(NSString *)screenId;
- (void)goToScreen:(id)sender :(id)object :(NSString *)screenId :(NSString *)transition;
- (void)goToPreviousScreen:(id)sender :(id)object;
- (void)goToPreviousScreen:(id)sender :(id)object :(NSString *)transition;
- (void)backToScreen:(id)sender :(id)object :(NSString *)screenId;
- (void)backToScreen:(id)sender :(id)object :(NSString *)screenId :(NSString *)transition;
- (void)backBySteps:(id)sender :(id)object :(NSString *)screenIndex;
- (void)backBySteps:(id)sender :(id)object :(NSString *)screenIndex :(NSString *)transition;
- (void)goToScreenWithContext:(id)sender :(id)object :(NSString *)screenId :(id)context;
- (void)goToScreenWithContext:(id)sender :(id)object :(NSString *)screenId :(id)context :(NSString *)transition;
- (void)goToProtectedScreen:(id)sender :(id)object;
- (void)previousElement:(id)sender :(id)object;
- (void)previousElement:(id)sender :(id)object :(NSString *)transition;
- (void)nextElement:(id)sender :(id)object;
- (void)nextElement:(id)sender :(id)object :(NSString *)transition;
- (void)refresh:(id)sender :(id)object;
- (void)reload:(id)sender :(id)object;
- (void)closePopup:(id)sender :(id)object;
- (void)loadmore:(id)sender :(id)object;
- (void)showOverlay:(id)sender :(id)object :(NSString *)overlayId;
- (void)hideOverlay:(id)sender :(id)object;
- (void)hideOverlayAndRefresh:(id)sender :(id)object;
- (void)hideOverlayAndReload:(id)sender :(id)object;
- (void)showAlert:(id)sender :(id)object :(NSString *)title :(NSString *)message :(NSString *)closeButtonTile :(NSString *)closeButtonAction :(NSString *)otherButtonTitle :(NSString *)otherButtonAction;

@end
