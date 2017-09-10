#import "AGSectionDesc+Layout.h"
#import "AGDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGControlDesc.h"
#import "AGLayoutManager.h"

@implementation AGSectionDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child prepareLayout];
    }
}

- (void)layout {
    AGAlignData alignData = [self getAlignAndVAlignDataForLayout];

    CGFloat controlPositionX = 0;
    CGFloat controlPositionY = 0;

    CGFloat posForTopVAlign = 0;
    CGFloat posForBottomVAlign = contentHeight-alignData.totalHeightForBottomVAlign;
    CGFloat posForCenterVAlign = (contentHeight-alignData.totalHeightForCenterVAlign)*0.5;
    CGFloat posForDistributedVAlign = 0;

    CGFloat freeSpaceForDistributedVAlign;

    if (alignData.elementsNoHeightVAlignDistributed == 1) {
        freeSpaceForDistributedVAlign = (contentHeight-alignData.totalHeightForDistributedVAlign)*0.5;
    } else {
        freeSpaceForDistributedVAlign = ((contentHeight-alignData.totalHeightForDistributedVAlign)/(alignData.elementsNoHeightVAlignDistributed-1));
    }

    if (posForCenterVAlign+alignData.totalHeightForCenterVAlign > posForBottomVAlign) {
        posForCenterVAlign = posForBottomVAlign-alignData.totalHeightForCenterVAlign;
    }
    if (posForCenterVAlign < posForTopVAlign+alignData.totalHeightForTopVAlign) {
        posForCenterVAlign = posForTopVAlign+alignData.totalHeightForTopVAlign;
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        // align
        if (child.align == alignLeft) {
            controlPositionX = 0;
        } else if (child.align == alignRight) {
            controlPositionX = contentWidth-child.blockWidth;
        } else if (child.align == alignCenter || child.align == alignDistributed) {
            controlPositionX = (contentWidth-child.blockWidth)*0.5;
        }

        // valign
        if (child.valign == valignTop) {
            controlPositionY = posForTopVAlign;
            posForTopVAlign += child.blockHeight;
        } else if (child.valign == valignCenter) {
            controlPositionY = posForCenterVAlign;
            posForCenterVAlign += child.blockHeight;
        } else if (child.valign == valignBottom) {
            controlPositionY = posForBottomVAlign;
            posForBottomVAlign += child.blockHeight;
        } else if (child.valign == valignDistributed) {
            if (alignData.elementsNoHeightVAlignDistributed == 1) {
                controlPositionY = posForDistributedVAlign+freeSpaceForDistributedVAlign;
            } else {
                controlPositionY = posForDistributedVAlign;
                posForDistributedVAlign += child.blockHeight+freeSpaceForDistributedVAlign;
            }
        }
        child.positionX = controlPositionX;
        child.positionY = controlPositionY;
        child.globalPositionX = positionX+child.positionX;
        child.globalPositionY = positionY+child.positionY;
    }

    [self layoutChildren];
}

- (void)layoutChildren {
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child layout];
    }
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    maxBlockWidth = maxWidth;
    maxBlockWidthForMax = maxSpaceForMax;

    width = maxSpaceForMax;
    contentWidth = maxSpaceForMax;
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    maxBlockHeight = maxHeight;
    maxBlockHeightForMax = maxSpaceForMax;

    CGFloat childrenHeightSum = 0;
    CGFloat maxHeightForChildren = maxHeight;

    if (hasVerticalScroll) {
        maxHeightForChildren = INFINITY;
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child measureBlockHeight:maxHeightForChildren withSpaceForMax:maxSpaceForMax];
        childrenHeightSum += child.blockHeight;
    }

    CGFloat minHeight = MIN(childrenHeightSum, maxHeight);
    height = minHeight;
    contentHeight = childrenHeightSum;
}

- (AGAlignData)getAlignAndVAlignDataForLayout {
    AGAlignData alignData = AGAlignDataZero();

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        // align
        if (child.align == alignLeft) {
            alignData.totalWidthForLeftAlign += child.blockWidth;
        } else if (child.align == alignRight) {
            alignData.totalWidthForRightAlign += child.blockWidth;
        } else if (child.align == alignCenter) {
            alignData.totalWidthForCenterAlign += child.blockWidth;
        } else if (child.align == alignDistributed) {
            alignData.totalWidthForDistributedAlign += child.blockWidth;
            alignData.elementsNoWidthAlignDistributed += 1;
        }

        // valign
        if (child.valign == valignTop) {
            alignData.totalHeightForTopVAlign += child.blockHeight;
        } else if (child.valign == valignCenter) {
            alignData.totalHeightForCenterVAlign += child.blockHeight;
        } else if (child.valign == valignBottom) {
            alignData.totalHeightForBottomVAlign += child.blockHeight;
        } else if (child.valign == valignDistributed) {
            alignData.totalHeightForDistributedVAlign += child.blockHeight;
            alignData.elementsNoHeightVAlignDistributed += 1;
        }
    }

    return alignData;
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
}

@end
