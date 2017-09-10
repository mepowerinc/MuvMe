#import "AGActivityIndicatorView.h"

@interface AGImageView : UIImageView {
    AGActivityIndicatorView *indicator;
    BOOL shouldShowActivityIndicator;
    BOOL useActivityIndicator;
}

@property(nonatomic, assign) BOOL shouldShowActivityIndicator;
@property(nonatomic, assign) BOOL useActivityIndicator;

@end
