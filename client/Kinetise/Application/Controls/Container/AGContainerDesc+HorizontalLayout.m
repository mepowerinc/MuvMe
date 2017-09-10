#import "AGContainerDesc+HorizontalLayout.h"
#import "AGControlDesc+Layout.h"
#import "AGContainerDesc+Layout.h"

@implementation AGContainerDesc (HorizontalLayout)

#pragma mark - Layout

- (void)horizontalLayout {
    AGAlignData alignData = [self getAlignAndVAlignDataForLayout];

    CGFloat controlPositionX = 0;
    CGFloat controlPositionY = 0;

    CGFloat horizontalSpaceForInnerBorder = [self getHorizontalSpaceForInnerBorder];
    CGFloat verticalSpaceForInnerBorder = [self getVerticalSpaceForInnerBorder];

    CGFloat posForLeftAlign = 0;
    CGFloat posForRightAlign = contentWidth-alignData.totalWidthForRightAlign;
    CGFloat posForCenterAlign = (contentWidth-alignData.totalWidthForCenterAlign)*0.5;
    CGFloat posForDistributedAlign = 0;

    CGFloat freeSpaceForDistributedAlign = 0;

    if (alignData.elementsNoWidthAlignDistributed == 1) {
        freeSpaceForDistributedAlign = (contentWidth-alignData.totalWidthForDistributedAlign)*0.5;
    } else {
        freeSpaceForDistributedAlign = (contentWidth-alignData.totalWidthForDistributedAlign) / (alignData.elementsNoWidthAlignDistributed-1);
    }

    if (posForCenterAlign+alignData.totalWidthForCenterAlign > posForRightAlign) {
        posForCenterAlign = posForRightAlign-alignData.totalWidthForCenterAlign;
    }
    if (posForCenterAlign < posForLeftAlign+alignData.totalWidthForLeftAlign) {
        posForCenterAlign = posForLeftAlign+alignData.totalWidthForLeftAlign;
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
            controlPositionX = posForLeftAlign;
            posForLeftAlign += child.blockWidth+horizontalSpaceForInnerBorder;
        } else if (child.align == alignRight) {
            controlPositionX = posForRightAlign;
            posForRightAlign += child.blockWidth+horizontalSpaceForInnerBorder;
        } else if (child.align == alignCenter) {
            controlPositionX = posForCenterAlign;
            posForCenterAlign += child.blockWidth+horizontalSpaceForInnerBorder;
        } else if (child.align == alignDistributed) {
            if (alignData.elementsNoWidthAlignDistributed == 1) {
                controlPositionX = posForDistributedAlign+freeSpaceForDistributedAlign;
            } else {
                controlPositionX = posForDistributedAlign;
                posForDistributedAlign += child.blockWidth+freeSpaceForDistributedAlign;
            }
        }

        // valign
        if (fabs(totalVerticalSpaceForInnerBorder) < FLT_EPSILON) {
            verticalSpaceForInnerBorder = 0;
        }

        totalVerticalSpaceForInnerBorder -= verticalSpaceForInnerBorder;

        if (child.valign == valignTop) {
            controlPositionY = 0;
        } else if (child.valign == valignCenter || child.valign == valignDistributed) {
            controlPositionY = ((contentHeight-child.blockHeight-verticalSpaceForInnerBorder)*0.5);
        } else if (child.valign == valignBottom) {
            controlPositionY = contentHeight-child.blockHeight-verticalSpaceForInnerBorder;
        }

        // set child position
        child.positionX = controlPositionX;
        child.positionY = controlPositionY;
        child.globalPositionX = globalPositionX+marginLeft.value+borderLeft.value+paddingLeft.value+child.positionX;
        child.globalPositionY = globalPositionY+marginTop.value+borderTop.value+paddingTop.value+child.positionY;
    }
}

#pragma mark - Min

- (void)horizontalMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    CGFloat result = 0;

    CGFloat horizontalSpaceForInnerBorder = [self getHorizontalSpaceForInnerBorder];
    CGFloat totalHorizontalSpaceForInnerBorder = [self getTotalHorizontalSpaceForInnerBorder];

    [self measureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (fabs(totalHorizontalSpaceForInnerBorder) < FLT_EPSILON) {
            horizontalSpaceForInnerBorder = 0;
        }
        totalHorizontalSpaceForInnerBorder -= horizontalSpaceForInnerBorder;
        result += child.blockWidth+horizontalSpaceForInnerBorder;
    }

    width.value = result;
}

- (void)horizontalMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    CGFloat result = 0;

    [self measureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (result < child.blockHeight) {
            result = child.blockHeight;
        }
    }

    height.value = result;
}

#pragma mark - Children

- (CGFloat)horizontalMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasHorizontalScroll) {
        maxWidth = INFINITY;
    }

    CGFloat childrenWidth = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.width.units == unitKpx || child.width.units == unitPercentage) {
            [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
            CGFloat childWidth = child.blockWidth+innerBorder.value;
            maxWidth -= childWidth;
            childrenWidth += childWidth;
            if (maxWidth < maxSpaceForMax) {
                maxSpaceForMax = maxWidth;
            }
        }
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.width.units == unitMin) {
            [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
            CGFloat childWidth = child.blockWidth+innerBorder.value;
            maxWidth -= childWidth;
            childrenWidth += childWidth;
            if (maxWidth < maxSpaceForMax) {
                maxSpaceForMax = maxWidth;
            }
        }
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.width.units == unitMax) {
            [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
            CGFloat childWidth = child.blockWidth+innerBorder.value;
            maxWidth -= childWidth;
            childrenWidth += childWidth;
            if (maxWidth < maxSpaceForMax) {
                maxSpaceForMax = maxWidth;
            }
        }
    }

    childrenWidth -= innerBorder.value;

    return childrenWidth;
}

- (CGFloat)horizontalMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasVerticalScroll) {
        maxHeight = INFINITY;
    }

    CGFloat result = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
        if (child.blockHeight > result) {
            result = child.blockHeight;
        }
    }

    return result;
}

@end
