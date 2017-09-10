#import "AGApplication.h"

@interface AGApplication (Overlay) <AGNavigationDrawerControllerDelegate>

- (void)showOverlay:(NSString *)overlayId;
- (void)hideOverlay;

@end
