#import <UIKit/UIKit.h>

@interface AGActivityIndicatorView : UIView {
    BOOL isAnimating;
    CGFloat animationDuration;
    BOOL shouldRestoreAnimation;
    CALayer *animationLayer;
}

@property(nonatomic, readonly) BOOL isAnimating;
@property(nonatomic, assign) CGFloat animationDuration;
@property(nonatomic, retain) UIImage *image;

- (void)startAnimating;
- (void)stopAnimating;
- (void)animate;

- (id)initWithImage:(UIImage *)image;

@end
