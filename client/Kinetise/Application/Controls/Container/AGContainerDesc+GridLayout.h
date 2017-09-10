#import "AGContainerDesc.h"

@interface AGContainerDesc (GridLayout)

- (void)gridLayout;
- (void)gridMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)gridMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)gridMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)gridMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;

@end
