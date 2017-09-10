#import "AGPopupDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGPopupDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    [controlDesc prepareLayout];
}

- (void)layout {
    [controlDesc layout];
    controlDesc.positionX = 0;
    controlDesc.positionY = 0;
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [controlDesc measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [controlDesc measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [controlDesc measureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [controlDesc measureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
}

@end
