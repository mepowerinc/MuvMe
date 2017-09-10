#import "UIView+Hierarchy.h"

@implementation UIView (Hierarchy)

- (NSInteger)getSubviewIndex {
    return [self.superview.subviews indexOfObjectIdenticalTo:self];
}

- (void)bringToFront {
    [self.superview bringSubviewToFront:self];
}

- (void)sentToBack {
    [self.superview sendSubviewToBack:self];
}

- (void)bringOneLevelUp {
    NSInteger currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex+1];
}

- (void)sendOneLevelDown {
    NSInteger currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex-1];
}

- (BOOL)isInFront {
    return ([self.superview.subviews lastObject] == self);
}

- (BOOL)isAtBack {
    return ([self.superview.subviews objectAtIndex:0] == self);
}

- (void)swapDepthsWithView:(UIView *)swapView {
    [self.superview exchangeSubviewAtIndex:[self getSubviewIndex] withSubviewAtIndex:[swapView getSubviewIndex]];
}

@end
