#import "AGControlDesc+Layout.h"
#import "AGNaviPanelDesc.h"
#import "AGBodyDesc.h"
#import "AGHeaderDesc.h"
#import "AGLayoutManager.h"
#import "AGDesc+Layout.h"
#import "AGContainerDesc.h"

@implementation AGControlDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {

}

- (void)layout {

}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    maxBlockWidth = maxWidth;
    maxBlockWidthForMax = maxSpaceForMax;

    [self measureMarginLeft];
    [self measureMarginRight];
    [self measureBorder];

    maxSpaceForMax = maxSpaceForMax - marginLeft.value - marginRight.value - borderLeft.value - borderRight.value;
    maxWidth = maxWidth - marginLeft.value - marginRight.value - borderLeft.value - borderRight.value;

    if (width.units == unitKpx) {
        [self measureWidthForKpxValue];
    } else if (width.units == unitPercentage) {
        [self measureWidthForPercentValue];
    } else if (width.units == unitMax) {
        [self measureWidthForMax:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (width.units == unitMin) {
        [self measurePaddingLeft];
        [self measurePaddingRight];
        [self measureWidthForMin:maxWidth-paddingLeft.value-paddingRight.value withSpaceForMax:maxSpaceForMax-paddingLeft.value-paddingRight.value];
    }

    if (width.units != unitMin) {
        [self measurePaddingLeft];
        [self measurePaddingRight];
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    maxBlockHeight = maxHeight;
    maxBlockHeightForMax = maxSpaceForMax;

    [self measureMarginTop];
    [self measureMarginBottom];

    maxSpaceForMax = maxSpaceForMax - marginTop.value - marginBottom.value - borderTop.value - borderBottom.value;
    maxHeight = maxHeight - marginTop.value - marginBottom.value - borderTop.value - borderBottom.value;

    if (height.units == unitKpx) {
        [self measureHeightForKpxValue];
    } else if (height.units == unitPercentage) {
        [self measureHeightForPercentValue];
    } else if (height.units == unitMax) {
        [self measureHeightForMax:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (height.units == unitMin) {
        [self measurePaddingTop];
        [self measurePaddingBottom];
        [self measureHeightForMin:maxHeight-paddingTop.value-paddingBottom.value withSpaceForMax:maxSpaceForMax-paddingTop.value-paddingBottom.value];
    }

    if (height.units != unitMin) {
        [self measurePaddingTop];
        [self measurePaddingBottom];
    }

    [self measureRadius];
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {

}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {

}

#pragma mark - Width

- (void)measureWidthForKpxValue {
    width.value = [AGLAYOUTMANAGER KPXToPixels:width.valueInUnits];
}

- (void)measureWidthForPercentValue {
    if (self.parent) {
        width.value = [AGLAYOUTMANAGER percentToPixels:width.valueInUnits withValue:parent.width.value];
    } else {
        width.value = [AGLAYOUTMANAGER percentToPixels:width.valueInUnits withValue:SCREEN_WIDTH];
    }
}

- (void)measureWidthForMax:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    width.value = maxSpaceForMax;
}

#pragma mark - Height

- (void)measureHeightForKpxValue {
    height.value = [AGLAYOUTMANAGER KPXToPixels:height.valueInUnits];
}

- (void)measureHeightForPercentValue {
    if (parent) {
        height.value = [AGLAYOUTMANAGER percentToPixels:height.valueInUnits withValue:parent.height.value];
    } else if ([section isKindOfClass:[AGBodyDesc class]]) {
        height.value = [AGLAYOUTMANAGER percentToPixels:height.valueInUnits withValue:[self bodyHeight]];
    } else if ([section isKindOfClass:[AGHeaderDesc class]]) {
        height.value = [AGLAYOUTMANAGER percentToPixels:height.valueInUnits withValue:SCREEN_HEIGHT];
    } else if ([section isKindOfClass:[AGNaviPanelDesc class]]) {
        height.value = [AGLAYOUTMANAGER percentToPixels:height.valueInUnits withValue:SCREEN_HEIGHT];
    }
}

- (void)measureHeightForMax:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if ([section isKindOfClass:[AGBodyDesc class]] && !parent) {
        height.value = [self bodyHeight] - marginTop.value - marginBottom.value - borderTop.value - borderBottom.value;
    } else {
        height.value = maxSpaceForMax;
    }
}

#pragma mark - Radius

- (void)measureRadius {
    radiusTopLeft.value = [AGLAYOUTMANAGER KPXToPixels:radiusTopLeft.valueInUnits];
    radiusTopRight.value = [AGLAYOUTMANAGER KPXToPixels:radiusTopRight.valueInUnits];
    radiusBottomLeft.value = [AGLAYOUTMANAGER KPXToPixels:radiusBottomLeft.valueInUnits];
    radiusBottomRight.value = [AGLAYOUTMANAGER KPXToPixels:radiusBottomRight.valueInUnits];

    CGFloat maxRadiusSize = MIN(width.value * 0.5f + borderLeft.value, height.value * 0.5f + borderTop.value);
    if (radiusTopLeft.value > maxRadiusSize) radiusTopLeft.value = maxRadiusSize;

    maxRadiusSize = MIN(width.value * 0.5f + borderRight.value, height.value * 0.5f + borderTop.value);
    if (radiusTopRight.value > maxRadiusSize) radiusTopRight.value = maxRadiusSize;

    maxRadiusSize = MIN(width.value * 0.5f + borderLeft.value, height.value * 0.5f + borderBottom.value);
    if (radiusBottomLeft.value > maxRadiusSize) radiusBottomLeft.value = maxRadiusSize;

    maxRadiusSize = MIN(width.value * 0.5f + borderRight.value, height.value * 0.5f + borderBottom.value);
    if (radiusBottomRight.value > maxRadiusSize) radiusBottomRight.value = maxRadiusSize;
}

#pragma mark - Body

- (CGFloat)bodyHeight {
    if ([section isKindOfClass:[AGBodyDesc class]]) {
        AGBodyDesc *bodyDesc = (AGBodyDesc *)section;
        return bodyDesc.height;
    }

    return SCREEN_HEIGHT;
}

#pragma mark - Border

- (void)measureBorder {
    borderLeft.value = [AGLAYOUTMANAGER KPXToPixels:borderLeft.valueInUnits];
    borderRight.value = [AGLAYOUTMANAGER KPXToPixels:borderRight.valueInUnits];
    borderTop.value = [AGLAYOUTMANAGER KPXToPixels:borderTop.valueInUnits];
    borderBottom.value = [AGLAYOUTMANAGER KPXToPixels:borderBottom.valueInUnits];
}

#pragma mark - Margin

- (CGFloat)measureMargin:(AGSize)margin useVerticalMargin:(BOOL)isMarginVertical {
    if (margin.units == unitKpx) {
        return [AGLAYOUTMANAGER KPXToPixels:margin.valueInUnits];
    } else if (margin.units == unitPercentage) {
        if (isMarginVertical) {
            if (parent) {
                return [AGLAYOUTMANAGER percentToPixels:margin.valueInUnits withValue:parent.height.value];
            } else if ([section isKindOfClass:[AGBodyDesc class]]) {
                return [AGLAYOUTMANAGER percentToPixels:margin.valueInUnits withValue:[self bodyHeight]];
            } else if ([section isKindOfClass:[AGHeaderDesc class]]) {
                return [AGLAYOUTMANAGER percentToPixels:margin.valueInUnits withValue:SCREEN_HEIGHT];
            } else if ([section isKindOfClass:[AGNaviPanelDesc class]]) {
                return [AGLAYOUTMANAGER percentToPixels:margin.valueInUnits withValue:SCREEN_HEIGHT];
            }
        } else {
            if (parent) {
                return [AGLAYOUTMANAGER percentToPixels:margin.valueInUnits withValue:parent.width.value];
            } else {
                return [AGLAYOUTMANAGER percentToPixels:margin.valueInUnits withValue:SCREEN_WIDTH];
            }
        }
    }

    return 0;
}

- (void)measureMarginLeft {
    marginLeft.value = [self measureMargin:marginLeft useVerticalMargin:NO];
}

- (void)measureMarginRight {
    marginRight.value = [self measureMargin:marginRight useVerticalMargin:NO];
}

- (void)measureMarginTop {
    marginTop.value = [self measureMargin:marginTop useVerticalMargin:YES];
}

- (void)measureMarginBottom {
    marginBottom.value = [self measureMargin:marginBottom useVerticalMargin:YES];
}

#pragma mark - Padding

- (CGFloat)measurePadding:(AGSize)padding useVerticalPadding:(BOOL)isPaddingVertical {
    if (padding.units == unitKpx) {
        return [AGLAYOUTMANAGER KPXToPixels:padding.valueInUnits];
    } else if (padding.units == unitPercentage) {
        if (isPaddingVertical) {
            return [AGLAYOUTMANAGER percentToPixels:padding.valueInUnits withValue:height.value];
        } else {
            return [AGLAYOUTMANAGER percentToPixels:padding.valueInUnits withValue:width.value];
        }
    }

    return 0;
}

- (void)measurePaddingLeft {
    paddingLeft.value = [self measurePadding:paddingLeft useVerticalPadding:NO];
}

- (void)measurePaddingRight {
    paddingRight.value = [self measurePadding:paddingRight useVerticalPadding:NO];
}

- (void)measurePaddingTop {
    paddingTop.value = [self measurePadding:paddingTop useVerticalPadding:YES];
}

- (void)measurePaddingBottom {
    paddingBottom.value = [self measurePadding:paddingBottom useVerticalPadding:YES];
}

@end
