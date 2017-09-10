#import "UIView+Debug.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Debug)
- (void)debugFrame {
    self.layer.borderColor = [UIColor greenColor].CGColor;
    self.layer.borderWidth = 1;
    for (UIView *subview in self.subviews) {
        [subview debugFrame];
    }
}

@end
