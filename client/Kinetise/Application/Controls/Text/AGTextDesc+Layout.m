#import "AGTextDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"
#import "AGApplication.h"

@implementation AGTextDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    // font size
    if (textStyle.useTextMultiplier) {
        textStyle.fontSize = AGSizeWithSize(textStyle.fontSize, [AGLAYOUTMANAGER KPXToPixels:textStyle.fontSize.valueInUnits]*AGAPPLICATION.textMultiplier);
    } else {
        textStyle.fontSize = AGSizeWithSize(textStyle.fontSize, [AGLAYOUTMANAGER KPXToPixels:textStyle.fontSize.valueInUnits]);
    }
    
    // string
    string.fontSize = textStyle.fontSize.value;
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];
    
    if (width.units == unitMin) {
        [self measureWidthForMin:maxWidth-paddingLeft.value-paddingRight.value-textStyle.textPaddingLeft.value-textStyle.textPaddingRight.value withSpaceForMax:maxSpaceForMax-paddingLeft.value-paddingRight.value-textStyle.textPaddingLeft.value-textStyle.textPaddingRight.value];
    }
    
    if (width.units != unitMin) {
        string.maxWidth = width.value-paddingLeft.value-paddingRight.value-textStyle.textPaddingLeft.value-textStyle.textPaddingRight.value;
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];
    
    if (height.units == unitMin) {
        [self measureHeightForMin:maxHeight-paddingTop.value-paddingBottom.value-textStyle.textPaddingTop.value-textStyle.textPaddingBottom.value withSpaceForMax:maxSpaceForMax-paddingTop.value-paddingBottom.value-textStyle.textPaddingTop.value-textStyle.textPaddingBottom.value];
    }
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    string.maxWidth = maxWidth;
    
    if (string.size.width > maxWidth) {
        width.value = maxWidth+paddingLeft.value+paddingRight.value+textStyle.textPaddingLeft.value+textStyle.textPaddingRight.value;
    } else {
        width.value = string.size.width+paddingLeft.value+paddingRight.value+textStyle.textPaddingLeft.value+textStyle.textPaddingRight.value;
    }
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    if (string.size.height > maxHeight) {
        height.value = maxHeight+paddingTop.value+paddingBottom.value+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value;
    } else {
        height.value = string.size.height+paddingTop.value+paddingBottom.value+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value;
    }
}

#pragma mark - Padding

- (void)measurePaddingLeft {
    [super measurePaddingLeft];
    
    textStyle.textPaddingLeft = AGSizeWithSize(textStyle.textPaddingLeft, [AGLAYOUTMANAGER KPXToPixels:textStyle.textPaddingLeft.valueInUnits]);
}

- (void)measurePaddingRight {
    [super measurePaddingRight];
    
    textStyle.textPaddingRight = AGSizeWithSize(textStyle.textPaddingRight, [AGLAYOUTMANAGER KPXToPixels:textStyle.textPaddingRight.valueInUnits]);
}

- (void)measurePaddingTop {
    [super measurePaddingTop];
    
    textStyle.textPaddingTop = AGSizeWithSize(textStyle.textPaddingTop, [AGLAYOUTMANAGER KPXToPixels:textStyle.textPaddingTop.valueInUnits]);
}

- (void)measurePaddingBottom {
    [super measurePaddingBottom];
    
    textStyle.textPaddingBottom = AGSizeWithSize(textStyle.textPaddingBottom, [AGLAYOUTMANAGER KPXToPixels:textStyle.textPaddingBottom.valueInUnits]);
}

@end
