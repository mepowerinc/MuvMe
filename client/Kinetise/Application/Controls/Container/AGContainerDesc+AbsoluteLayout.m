#import "AGContainerDesc+AbsoluteLayout.h"
#import "AGControlDesc+Layout.h"
#import "AGContainerDesc+Layout.h"

@implementation AGContainerDesc (AbsoluteLayout)

- (void)absoluteLayout {
    CGFloat controlPositionX = 0;
    CGFloat controlPositionY = 0;
    
    for (int i = 0; i < children.count; ++i) {
        AGControlDesc *child = children[i];
        
        // exclude
        if (child.excludeFromCalculate) continue;
        
        // invert
        if (invertChildren) {
            child = children[children.count-1-i];
        }
        
        // align
        if (child.align == alignLeft) {
            controlPositionX = 0;
        } else if (child.align == alignRight) {
            controlPositionX = contentWidth-child.blockWidth;
        } else if (child.align == alignCenter || child.align == alignDistributed) {
            controlPositionX = ((contentWidth-child.blockWidth)*0.5);
        }
        
        // valign
        if (child.valign == valignTop) {
            controlPositionY = 0;
        } else if (child.valign == valignCenter || child.valign == valignDistributed) {
            controlPositionY = ((contentHeight-child.blockHeight)*0.5);
        } else if (child.valign == valignBottom) {
            controlPositionY = contentHeight-child.blockHeight;
        }
        
        // set child position
        child.positionX = controlPositionX;
        child.positionY = controlPositionY;
        child.globalPositionX = globalPositionX+marginLeft.value+borderLeft.value+paddingLeft.value+child.positionX;
        child.globalPositionY = globalPositionY+marginTop.value+borderTop.value+paddingTop.value+child.positionY;
    }
}

- (void)absoluteMeasureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    width.value = [self measureWidthForChildren:maxWidth withSpaceForMax:maxSpaceForMax];
}

- (void)absoluteMeasureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    height.value = [self measureHeightForChildren:maxHeight withSpaceForMax:maxSpaceForMax];
}

- (CGFloat)absoluteMeasureWidthForChildren:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (hasHorizontalScroll) {
        maxWidth = INFINITY;
    }
    
    CGFloat result = 0;
    
    for (AGControlDesc *child in children) {
        if (child.excludeFromCalculate) continue;
        
        [child measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
        if (child.blockWidth > result) {
            result = child.blockWidth;
        }
    }
    
    return result;
}

- (CGFloat)absoluteMeasureHeightForChildren:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
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
