#import "AGScrollView.h"

@implementation AGScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.directionalLockEnabled = YES;
    self.delaysContentTouches = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;

    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}

@end
