#import "AGPresenterController.h"
#import "AGPopup.h"

@interface AGPopupController : AGPresenterController

- (void)present:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss:(BOOL)animated completion:(void (^)(void))completion;

@end
