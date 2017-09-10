#import <UIKit/UIKit.h>

typedef void (^AGTouchedOutsideBlock)();

@interface AGValidationPopoverView : UIView

@property(nonatomic, copy) AGTouchedOutsideBlock touchOutsideBlock;

@end
