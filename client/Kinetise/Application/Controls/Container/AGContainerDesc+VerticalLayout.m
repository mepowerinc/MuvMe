#import "AGContainerDesc+VerticalLayout.h"
#import "AGControlDesc+Layout.h"
#import "AGContainerDesc+Layout.h"

@implementation AGContainerDesc (VerticalLayout)

#pragma mark - Layout

- (void)verticalLayout {
    AGAlignData alignData = [self getAlignAndVAlignDataForLayout];

    CGFloat controlPositionX = 0;
    CGFloat controlPositionY = 0;

    CGFloat horizontalSpaceForInnerBorder = [self getHorizontalSpaceForInnerBorder];
    CGFloat verticalSpaceForInnerBorder = [self getVerticalSpaceForInnerBorder];

    CGFloat posForTopVAlign = 0;
    CGFloat posForBottomVAlign = contentHeight-alignData.totalHeightForBottomVAlign;
    CGFloat posForCenterVAlign = (contentHeight-alignData.totalHeightForCenterVAlign)*0.5;
    CGFloat posForDistributedVAlign = 0;

    CGFloat freeSpaceForDistributedVAlign = 0;

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

    CGFloat totalHorizontalSpaceForInnerBorder = [self getTotalHorizontalSpaceForInnerBorder];
    CGFloat totalVerticalSpaceForInnerBorder = [self getTotalVerticalSpaceForInnerBorder];

    for (int i = 0; i < children.count; ++i) {
        AGControlDesc *child = children[i];

        // exclude
        if (child.excludeFromCalculate) continue;

        // invert
        if (invertChildren) {
            child = children[children.count-1-i];
        }

        // align
        if (fabs(totalHorizontalSpaceForInnerBorder) < FLT_EPSILON) {
            horizontalSpaceForInnerBorder = 0;
        }

        totalHorizontalSpaceForInnerBorder -= horizontalSpaceForInnerBorder;

        if (child.align == alignLeft) {
            controlPositionX = 0;
        } else if (child.align == alignRight) {
            controlPositionX = contentWidth-child.blockWidth-horizontalSpaceForInnerBorder;
        } else if (child.align == alignCenter || child.align == alignDistributed) {
            controlPositionX = ((contentWidth-child.blockWidth-horizontalSpaceForInnerBorder)*0.5);
        }

        // valign
        if (fabs(totalVerticalSpaceForInnerBorder) < FLT_EPSILON) {
            verticalSpaceForInnerBorder = 0;
        }

        totalVerticalSpaceForInnerBorder -= verticalSpaceForInnerBorder;

        if (child.valign == valignTop) {
            controlPositionY = posForTopVAlign;
            posForTopVAlign += child.blockHeight+verticalSpaceForInnerBorder;
        } else if (child.valign == valignCenter) {
            controlPositionY = posForCenterVAlign;
            posForCenterVAlign += child.blockHeight+verticalSpaceForInnerBorder;
        } else if (child.valign == valignBottom) {
            controlPositionY = posForBottomVAlign;
            posForBottomVAlign += child.blockHeight+verticalSpaceForInnerBorder;
        } else if (child.valign == valignDistributed) {
            if (alignData.elementsNoHeightVAlignDistributed == 1) {
                controlPositionY = posForDistributedVAlign+freeSpaceForDistributedVAlign;
            } else {
                controlPositionY = posForDistributedVAlign;
                posForDistributedVAlign += child.blockHeight+freeSpaceForDistributedVAlign;
            }
        }

        // set child position
        child.positionX = controlPositionX;
        child.positionY = controlPositionY;
        child.globalPositionX = globalPositionX+marginLeft.value+borderLeft.value+paddingLeft.value+child.positionX;
        child.globalPositionY = globalPositionY+marginTop.value+borderTop.value+paddingTop.value+child.positionY;
    }
}

#pragma mark - Min

- (void)verticalMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    CGFloat result = 0;

    [self measureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (result < child.blockWidth) {
            result = child.blockWidth;
        }
    }

    width.value = result;
}

- (void)verticalMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    CGFloat result = 0;

    CGFloat totalVerticalSpaceForInnerBorder = [self getTotalVerticalSpaceForInnerBorder];

    [self measureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        result += child.blockHeight;
    }

    result += totalVerticalSpaceForInnerBorder;
    height.value = result;
}

#pragma mark - Children

- (CGFloat)verticalMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasHorizontalScroll) {
        maxWidth = INFINITY;
    }

    CGFloat maxChild = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
        maxChild = MAX(child.blockWidth, maxChild);
    }

    return maxChild;
}

- (CGFloat)verticalMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasVerticalScroll) {
        maxHeight = INFINITY;
    }

    CGFloat childrenHeight = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.height.units == unitKpx || child.height.units == unitPercentage) {
            [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
            CGFloat childHeight = child.blockHeight+innerBorder.value;
            maxHeight -= childHeight;
            childrenHeight += childHeight;
            if (maxHeight < maxSpaceForMax) {
                maxSpaceForMax = maxHeight;
            }
        }
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.height.units == unitMin) {
            [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
            CGFloat childHeight = child.blockHeight+innerBorder.value;
            maxHeight -= childHeight;
            childrenHeight += childHeight;
            if (maxHeight < maxSpaceForMax) {
                maxSpaceForMax = maxHeight;
            }
        }
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.height.units == unitMax) {
            [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
            CGFloat childHeight = child.blockHeight+innerBorder.value;
            maxHeight -= childHeight;
            childrenHeight += childHeight;
            if (maxHeight < maxSpaceForMax) {
                maxSpaceForMax = maxHeight;
            }
        }
    }

    childrenHeight -= innerBorder.value;

    return childrenHeight;
}

@end
