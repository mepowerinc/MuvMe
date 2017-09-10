#import "AGOverlayDesc+Layout.h"
#import "AGPopupDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGOverlayDesc (Layout)

#pragma mark - Layout

- (void)layout {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [controlDesc layout];
    controlDesc.positionX = 0;
    controlDesc.positionY = statusBarHeight;
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [controlDesc measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    
    if (offset.units == unitKpx) {
        offset.value = [AGLAYOUTMANAGER KPXToPixels:offset.valueInUnits];
    } else if (offset.units == unitPercentage) {
        offset.value = [AGLAYOUTMANAGER percentToPixels:offset.valueInUnits withValue:maxWidth];
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    maxHeight -= statusBarHeight;
    maxSpaceForMax -= statusBarHeight;
    
    [controlDesc measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
}

@end
