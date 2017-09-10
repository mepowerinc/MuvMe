#import <UIKit/UIKit.h>

@interface UIView (Hierarchy)

- (NSInteger)getSubviewIndex;

- (void)bringToFront;
- (void)sentToBack;

- (void)bringOneLevelUp;
- (void)sendOneLevelDown;

- (BOOL)isInFront;
- (BOOL)isAtBack;

- (void)swapDepthsWithView:(UIView *)swapView;

@end