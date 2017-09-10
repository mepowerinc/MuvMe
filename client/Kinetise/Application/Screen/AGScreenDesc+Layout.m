#import "AGScreenDesc+Layout.h"
#import "AGDesc+Layout.h"
#import "AGSectionDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGScreenDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    if (header) {
        [header prepareLayout];
    }
    if (naviPanel) {
        [naviPanel prepareLayout];
    }
    if (body) {
        [body prepareLayout];
    }
}

- (void)layout {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    if (header) {
        [header layout];
        header.positionX = 0;
        header.positionY = statusBarHeight;
    }
    if (body) {
        [body layout];
        body.positionX = 0;
        body.positionY = statusBarHeight+header.height;
    }
    if (naviPanel) {
        [naviPanel layout];
        naviPanel.positionX = 0;
        naviPanel.positionY = body.positionY+body.height;
    }
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    width = maxWidth;
    
    if (header) {
        [header measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    }
    if (naviPanel) {
        [naviPanel measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    }
    if (body) {
        [body measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    height = maxHeight;
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    maxHeight -= statusBarHeight;
    maxSpaceForMax -= statusBarHeight;
    
    CGFloat headerHeight = 0;
    if (header) {
        [header measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
        headerHeight = header.height;
    }
    
    CGFloat naviPanelHeight = 0;
    if (naviPanel) {
        [naviPanel measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
        naviPanelHeight = naviPanel.height;
    }
    
    if (body) {
        [body measureBlockHeight:maxHeight-headerHeight-naviPanelHeight withSpaceForMax:maxHeight-headerHeight-naviPanelHeight];
    }
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
}

@end
