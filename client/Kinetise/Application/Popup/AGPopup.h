#import "AGPresenter.h"
#import "AGPopupDesc.h"
#import "AGControl.h"

@interface AGPopup : AGPresenter {
    AGControl *control;
}

@property(nonatomic, retain) AGControl *control;

@end
