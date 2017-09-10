#import "AGMapDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGMapDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    [super prepareLayout];

    [indicatorDesc prepareLayout];
}

- (void)layout {
    [super layout];

    AGAlignData alignData = [self getAlignAndVAlignDataForLayout];

    CGFloat contentWidth = width.value-paddingLeft.value-paddingRight.value;
    CGFloat contentHeight = height.value-paddingTop.value-paddingBottom.value;

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

    // align
    if (indicatorDesc.align == alignLeft) {
        controlPositionX = 0;
    } else if (indicatorDesc.align == alignRight) {
        controlPositionX = contentWidth-indicatorDesc.blockWidth;
    } else if (indicatorDesc.align == alignCenter || indicatorDesc.align == alignDistributed) {
        controlPositionX = (contentWidth-indicatorDesc.blockWidth)*0.5;
    }

    // valign
    if (indicatorDesc.valign == valignTop) {
        controlPositionY = posForTopVAlign;
        posForTopVAlign += indicatorDesc.blockHeight;
    } else if (indicatorDesc.valign == valignCenter) {
        controlPositionY = posForCenterVAlign;
        posForCenterVAlign += indicatorDesc.blockHeight;
    } else if (indicatorDesc.valign == valignBottom) {
        controlPositionY = posForBottomVAlign;
        posForBottomVAlign += indicatorDesc.blockHeight;
    } else if (indicatorDesc.valign == valignDistributed) {
        if (alignData.elementsNoHeightVAlignDistributed == 1) {
            controlPositionY = posForDistributedVAlign+freeSpaceForDistributedVAlign;
        } else {
            controlPositionY = posForDistributedVAlign;
            posForDistributedVAlign += indicatorDesc.blockHeight+freeSpaceForDistributedVAlign;
        }
    }
    indicatorDesc.positionX = controlPositionX;
    indicatorDesc.positionY = controlPositionY;
    indicatorDesc.globalPositionX = positionX+indicatorDesc.positionX;
    indicatorDesc.globalPositionY = positionY+indicatorDesc.positionY;

    [indicatorDesc layout];
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];

    // pin size
    pinSize.value = [AGLAYOUTMANAGER KPXToPixels:pinSize.valueInUnits];

    // indicator
    [indicatorDesc measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];

    // indicator
    [indicatorDesc measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
}

- (AGAlignData)getAlignAndVAlignDataForLayout {
    AGAlignData alignData = AGAlignDataZero();

    // align
    if (indicatorDesc.align == alignLeft) {
        alignData.totalWidthForLeftAlign += indicatorDesc.blockWidth;
    } else if (indicatorDesc.align == alignRight) {
        alignData.totalWidthForRightAlign += indicatorDesc.blockWidth;
    } else if (indicatorDesc.align == alignCenter) {
        alignData.totalWidthForCenterAlign += indicatorDesc.blockWidth;
    } else if (indicatorDesc.align == alignDistributed) {
        alignData.totalWidthForDistributedAlign += indicatorDesc.blockWidth;
        alignData.elementsNoWidthAlignDistributed += 1;
    }

    // valign
    if (indicatorDesc.valign == valignTop) {
        alignData.totalHeightForTopVAlign += indicatorDesc.blockHeight;
    } else if (indicatorDesc.valign == valignCenter) {
        alignData.totalHeightForCenterVAlign += indicatorDesc.blockHeight;
    } else if (indicatorDesc.valign == valignBottom) {
        alignData.totalHeightForBottomVAlign += indicatorDesc.blockHeight;
    } else if (indicatorDesc.valign == valignDistributed) {
        alignData.totalHeightForDistributedVAlign += indicatorDesc.blockHeight;
        alignData.elementsNoHeightVAlignDistributed += 1;
    }

    return alignData;
}

@end
