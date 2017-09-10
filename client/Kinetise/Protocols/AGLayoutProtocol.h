#import "AGUnits.h"

@protocol AGLayoutProtocol <NSObject>

- (void)prepareLayout;
- (void)layout;
- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
@optional
- (void)layoutChildren;
- (AGAlignData)getAlignAndVAlignDataForLayout;
- (CGFloat)measureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)measureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax;
- (CGFloat)getHorizontalSpaceForInnerBorder;
- (CGFloat)getVerticalSpaceForInnerBorder;
- (CGFloat)getTotalHorizontalSpaceForInnerBorder;
- (CGFloat)getTotalVerticalSpaceForInnerBorder;
- (CGFloat)calcSpaceForInnerBorder;

@end
