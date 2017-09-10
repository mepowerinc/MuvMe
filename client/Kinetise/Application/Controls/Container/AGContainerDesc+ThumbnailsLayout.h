#import "AGContainerDesc.h"

@interface AGContainerDesc (ThumbnailsLayout)

- (void)thumbnailsLayout;
- (void)thumbnailsMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)thumbnailsMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)thumbnailsMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)thumbnailsMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;

@end
