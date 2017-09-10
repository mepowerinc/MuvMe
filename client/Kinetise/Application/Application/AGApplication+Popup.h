#import "AGApplication.h"

@interface AGApplication (Popup)

- (void)showAlert:(NSString *)title message:(NSString *)message andCancelButton:(NSString *)cancelButton;
- (void)showAlert:(NSString *)title message:(NSString *)message;
- (void)showInfoPopup:(NSString *)message;
- (void)showErrorPopup:(NSString *)message;
- (void)showPopup:(AGControlDesc *)controlDesc;
- (void)hidePopup;

@end
