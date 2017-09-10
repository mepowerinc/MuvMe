#import <UIKit/UIKit.h>
#import "AGPresenter.h"

@interface AGPresenterController : UIViewController {
    AGPresenter *presenter;
    CGSize prevFrameSize;
}

@property(nonatomic, retain) AGPresenter *presenter;

@end
