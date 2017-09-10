#import <UIKit/UIKit.h>

@interface AGToastView : UIView {
    UILabel *label;
    BOOL isAnimating;
}

@property(nonatomic, assign) NSInteger bottomMargin;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, retain) UIColor *color;

- (void)show;
- (void)hide;
- (void)showWithCompletionBlock:(void (^)(void))completionBlock;
- (void)hideWithCompletionBlock:(void (^)(void))completionBlock;

@end
