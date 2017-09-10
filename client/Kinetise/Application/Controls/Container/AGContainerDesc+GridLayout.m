#import "AGContainerDesc+GridLayout.h"
#import "AGControlDesc+Layout.h"
#import "AGContainerDesc+Layout.h"

@implementation AGContainerDesc (GridLayout)

#pragma mark - Layout

- (void)gridLayout {
    CGFloat horizontalSpaceForInnerBorder = [self getHorizontalSpaceForInnerBorder];
    CGFloat verticalSpaceForInnerBorder = [self getVerticalSpaceForInnerBorder];

    CGFloat posForLeftAlign = 0;
    CGFloat posForTopVAlign = 0;

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        NSInteger controlIndex = [children indexOfObject:child];
        NSInteger row = controlIndex/columns;
        NSInteger column = controlIndex%columns;

        // set child position
        child.positionX = posForLeftAlign + column * (child.blockWidth + verticalSpaceForInnerBorder);
        child.positionY = posForTopVAlign + row * (child.blockHeight + horizontalSpaceForInnerBorder);
        child.globalPositionX = globalPositionX+marginLeft.value+borderLeft.value+paddingLeft.value+child.positionX;
        child.globalPositionY = globalPositionY+marginTop.value+borderTop.value+paddingTop.value+child.positionY;
    }
}

#pragma mark - Min

- (void)gridMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    width.value = [self measureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)gridMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    height.value = [self measureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
}

#pragma mark - Children

- (CGFloat)gridMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasHorizontalScroll) {
        maxWidth = INFINITY;
    }

    NSInteger numOfColumns = columns;
    if (children.count < numOfColumns) numOfColumns = children.count;

    CGFloat childrenWidth = 0;
    CGFloat childWidth = 0;

    if (children.count) {
        AGControlDesc *child = children[0];
        if (child.width.units == unitKpx || child.width.units == unitPercentage) {
            [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
            childWidth = child.blockWidth+innerBorder.value;
        }
    }

    childrenWidth = numOfColumns * childWidth;
    maxWidth -= childrenWidth;
    if (maxWidth < maxSpaceForMax) {
        maxSpaceForMax = maxWidth;
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.width.units == unitKpx || child.width.units == unitPercentage) {
            [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
        }
    }

    childrenWidth -= innerBorder.value;

    return childrenWidth;
}

- (CGFloat)gridMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasVerticalScroll) {
        maxHeight = INFINITY;
    }

    NSInteger numOfRows = ceilf(children.count/(float)columns);
    if (children.count < columns) numOfRows = 1;

    CGFloat childrenHeight = 0;
    CGFloat childHeight = 0;

    if (children.count) {
        AGControlDesc *child = children[0];
        if (child.width.units == unitKpx || child.width.units == unitPercentage) {
            [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
            childHeight = child.blockHeight+innerBorder.value;
        }
    }

    childrenHeight = numOfRows * childHeight;
    maxHeight -= childrenHeight;
    if (maxHeight < maxSpaceForMax) {
        maxSpaceForMax = maxHeight;
    }

    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;

        if (child.height.units == unitKpx || child.height.units == unitPercentage) {
            [child measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
        }
    }

    childrenHeight -= innerBorder.value;

    return childrenHeight;
}

@end
