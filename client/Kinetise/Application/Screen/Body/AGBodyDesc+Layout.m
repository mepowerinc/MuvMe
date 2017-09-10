#import "AGBodyDesc+Layout.h"
#import "AGSectionDesc+Layout.h"
#import "AGControlDesc+Layout.h"

@implementation AGBodyDesc (Layout)

#pragma mark - Layout

- (void)layout {
    AGAlignData alignData = [self getAlignAndVAlignDataForLayout];

    CGFloat controlPositionX = 0;
    CGFloat controlPositionY = 0;

    CGFloat localContentWidth = contentWidth;
    CGFloat localContentHeight = contentHeight;

    CGFloat posForTopVAlign = 0;
    CGFloat posForBottomVAlign = posForTopVAlign+(localContentHeight-alignData.totalHeightForBottomVAlign);
    CGFloat posForCenterVAlign = posForTopVAlign+(localContentHeight-alignData.totalHeightForCenterVAlign)*0.5;
    CGFloat posForDistributedVAlign = posForTopVAlign;

    CGFloat freeSpaceForDistributedVAlign = 0;
    if (alignData.elementsNoHeightVAlignDistributed == 1) {
        freeSpaceForDistributedVAlign = (localContentHeight-alignData.totalHeightForDistributedVAlign)*0.5;
    } else {
        freeSpaceForDistributedVAlign = ((localContentHeight-alignData.totalHeightForDistributedVAlign)/(alignData.elementsNoHeightVAlignDistributed-1));
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
            controlPositionX = localContentWidth-child.blockWidth;
        } else if (child.align == alignCenter || child.align == alignDistributed) {
            controlPositionX = (localContentWidth-child.blockWidth)*0.5;
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

#pragma mark - Measure

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

    height = maxHeight;
    contentHeight = childrenHeightSum;
}

@end
