#import "AGApplicationDesc+Layout.h"
#import "AGDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGApplicationDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {

}

- (void)layout {
    NSArray *screensDescs = [screens allValues];
    for (AGScreenDesc *screenDesc in screensDescs) {
        [AGLAYOUTMANAGER layout:screenDesc withSize:AGLAYOUTMANAGER.screenSize];
    }
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
}

@end
