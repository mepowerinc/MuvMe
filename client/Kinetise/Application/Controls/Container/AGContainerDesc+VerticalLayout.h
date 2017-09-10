#import "AGContainerDesc.h"

@interface AGContainerDesc (VerticalLayout)

- (void)verticalLayout;
- (void)verticalMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)verticalMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)verticalMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)verticalMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;

@end
