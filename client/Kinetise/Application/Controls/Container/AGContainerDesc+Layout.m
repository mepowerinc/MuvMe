#import "AGContainerDesc+Layout.h"
#import "AGLayoutManager.h"
#import "AGControlDesc+Layout.h"
#import "AGContainerDesc+HorizontalLayout.h"
#import "AGContainerDesc+VerticalLayout.h"
#import "AGContainerDesc+ThumbnailsLayout.h"
#import "AGContainerDesc+GridLayout.h"
#import "AGContainerDesc+AbsoluteLayout.h"

@implementation AGContainerDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;
        
        [child prepareLayout];
    }
}

- (void)layout {
    if (containerLayout == layoutHorizontal) {
        [self horizontalLayout];
    } else if (containerLayout == layoutVertical) {
        [self verticalLayout];
    } else if (containerLayout == layoutThumbnails) {
        [self thumbnailsLayout];
    } else if (containerLayout == layoutGrid) {
        [self gridLayout];
    } else if (containerLayout == layoutAbsolute) {
        [self absoluteLayout];
    }
    
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;
        
        [child layout];
    }
}

#pragma mark - Block

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [self measureInnerBorder];
    
    [super measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    
    if (width.units != unitMin) {
        maxWidth = width.value-paddingLeft.value-paddingRight.value;
        maxSpaceForMax = maxWidth;
        
        CGFloat childrenWidth = [self measureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
        CGFloat viewport = width.value-paddingLeft.value-paddingRight.value;
        
        if (hasHorizontalScroll) {
            contentWidth = MAX(viewport, childrenWidth);
        } else {
            contentWidth = viewport;
        }
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
    
    if (height.units != unitMin) {
        maxHeight = height.value-paddingTop.value-paddingBottom.value;
        maxSpaceForMax = maxHeight;
        
        CGFloat childrenHeight = [self measureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
        CGFloat viewport = height.value-paddingTop.value-paddingBottom.value;
        
        if (hasVerticalScroll) {
            contentHeight = MAX(viewport, childrenHeight);
        } else {
            contentHeight = viewport;
        }
    }
}

#pragma mark - Min

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (containerLayout == layoutHorizontal) {
        [self horizontalMeasureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutVertical) {
        [self verticalMeasureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutThumbnails) {
        [self thumbnailsMeasureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutGrid) {
        [self gridMeasureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutAbsolute) {
        [self absoluteMeasureWidthForMin:maxWidth withSpaceForMax:maxSpaceForMax];
    }
    
    CGFloat measuredWidth = width.value;
    contentWidth = measuredWidth;
    
    if (maxWidth < measuredWidth) {
        measuredWidth = maxWidth;
    }
    
    width.value = measuredWidth+paddingLeft.value+paddingRight.value;
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (containerLayout == layoutHorizontal) {
        [self horizontalMeasureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutVertical) {
        [self verticalMeasureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutThumbnails) {
        [self thumbnailsMeasureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutGrid) {
        [self gridMeasureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutAbsolute) {
        [self absoluteMeasureHeightForMin:maxHeight withSpaceForMax:maxSpaceForMax];
    }
    
    CGFloat measuredHeight = height.value;
    contentHeight = measuredHeight;
    
    if (maxHeight < measuredHeight) {
        measuredHeight = maxHeight;
    }
    
    height.value = measuredHeight+paddingTop.value+paddingBottom.value;
}

#pragma mark - Children

- (CGFloat)measureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (containerLayout == layoutHorizontal) {
        return [self horizontalMeasureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutVertical) {
        return [self verticalMeasureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutThumbnails) {
        return [self thumbnailsMeasureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutGrid) {
        return [self gridMeasureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutAbsolute) {
        return [self absoluteMeasureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
    }
    
    return 0;
}

- (CGFloat)measureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (containerLayout == layoutHorizontal) {
        return [self horizontalMeasureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutVertical) {
        return [self verticalMeasureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutThumbnails) {
        return [self thumbnailsMeasureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutGrid) {
        return [self gridMeasureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
    } else if (containerLayout == layoutAbsolute) {
        return [self absoluteMeasureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
    }
    
    return 0;
}

#pragma mark - Align

- (AGAlignData)getAlignAndVAlignDataForLayout {
    AGAlignData alignData = AGAlignDataZero();
    
    CGFloat horizontalSpaceForInnerBorder = [self getHorizontalSpaceForInnerBorder];
    CGFloat verticalSpaceForInnerBorder = [self getVerticalSpaceForInnerBorder];
    CGFloat totalHorizontalSpaceForInnerBorder = [self getTotalHorizontalSpaceForInnerBorder];
    CGFloat totalVerticalSpaceForInnerBorder = [self getTotalVerticalSpaceForInnerBorder];
    
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;
        
        // align
        if (fabs(totalHorizontalSpaceForInnerBorder) < FLT_EPSILON) {
            horizontalSpaceForInnerBorder = 0;
        }
        
        totalHorizontalSpaceForInnerBorder -= horizontalSpaceForInnerBorder;
        
        if (child.align == alignLeft) {
            alignData.totalWidthForLeftAlign += child.blockWidth+horizontalSpaceForInnerBorder;
        } else if (child.align == alignRight) {
            alignData.totalWidthForRightAlign += child.blockWidth+horizontalSpaceForInnerBorder;
        } else if (child.align == alignCenter) {
            alignData.totalWidthForCenterAlign += child.blockWidth+horizontalSpaceForInnerBorder;
        } else if (child.align == alignDistributed) {
            alignData.totalWidthForDistributedAlign += child.blockWidth;
            alignData.elementsNoWidthAlignDistributed += 1;
        }
        
        // valign
        if (fabs(totalVerticalSpaceForInnerBorder) < FLT_EPSILON) {
            verticalSpaceForInnerBorder = 0;
        }
        
        totalVerticalSpaceForInnerBorder -= verticalSpaceForInnerBorder;
        
        if (child.valign == valignTop) {
            alignData.totalHeightForTopVAlign += child.blockHeight+verticalSpaceForInnerBorder;
        } else if (child.valign == valignCenter) {
            alignData.totalHeightForCenterVAlign += child.blockHeight+verticalSpaceForInnerBorder;
        } else if (child.valign == valignBottom) {
            alignData.totalHeightForBottomVAlign += child.blockHeight+verticalSpaceForInnerBorder;
        } else if (child.valign == valignDistributed) {
            alignData.totalHeightForDistributedVAlign += child.blockHeight;
            alignData.elementsNoHeightVAlignDistributed += 1;
        }
    }
    
    return alignData;
}

- (NSInteger)countChildren {
    NSInteger count = 0;
    
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;
        
        ++count;
    }
    
    return count;
}

- (CGFloat)calcSpaceForInnerBorder {
    NSInteger childrenCount = [self countChildren];
    
    if (childrenCount > 1) {
        return innerBorder.value*(childrenCount-1);
    }
    
    return 0;
}

#pragma mark - Border

- (void)measureInnerBorder {
    innerBorder.value = [AGLAYOUTMANAGER KPXToPixels:innerBorder.valueInUnits];
}

- (CGFloat)getHorizontalSpaceForInnerBorder {
    if (containerLayout == layoutHorizontal || containerLayout == layoutGrid) {
        if ([self countChildren] > 1) {
            return innerBorder.value;
        }
    }
    return 0;
}

- (CGFloat)getVerticalSpaceForInnerBorder {
    if (containerLayout == layoutVertical || containerLayout == layoutGrid) {
        if ([self countChildren] > 1) {
            return innerBorder.value;
        }
    }
    return 0;
}

- (CGFloat)getTotalHorizontalSpaceForInnerBorder {
    if (containerLayout == layoutHorizontal || containerLayout == layoutGrid) {
        return [self calcSpaceForInnerBorder];
    }
    return 0;
}

- (CGFloat)getTotalVerticalSpaceForInnerBorder {
    if (containerLayout == layoutVertical || containerLayout == layoutGrid) {
        return [self calcSpaceForInnerBorder];
    }
    return 0;
}

@end
