#import "AGContainerDesc.h"

@interface AGContainerDesc (HorizontalLayout)

- (void)horizontalLayout;
- (void)horizontalMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)horizontalMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)horizontalMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)horizontalMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;

@end
