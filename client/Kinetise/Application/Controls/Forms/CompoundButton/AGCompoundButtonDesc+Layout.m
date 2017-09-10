#import "AGCompoundButtonDesc+Layout.h"
#import "AGTextDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGCompoundButtonDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    [super prepareLayout];

    checkWidth.value = [AGLAYOUTMANAGER KPXToPixels:checkWidth.valueInUnits];
    checkHeight.value = [AGLAYOUTMANAGER KPXToPixels:checkHeight.valueInUnits];

    if (text.value.length) {
        innerSpace.value = [AGLAYOUTMANAGER KPXToPixels:innerSpace.valueInUnits];
    } else {
        innerSpace.value = 0;
    }
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];

    if (width.units != unitMin) {
        string.maxWidth = width.value-paddingLeft.value-paddingRight.value-textStyle.textPaddingLeft.value-textStyle.textPaddingRight.value-checkWidth.value-innerSpace.value;
    }
}

- (void)measureWidthForMin:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    string.maxWidth = maxWidth-checkWidth.value-innerSpace.value;

    if (string.size.width+innerSpace.value+checkWidth.value > maxWidth) {
        width.value = maxWidth+innerSpace.value+checkWidth.value+paddingLeft.value+paddingRight.value+textStyle.textPaddingLeft.value+textStyle.textPaddingRight.value;
    } else {
        width.value = string.size.width+innerSpace.value+checkWidth.value+paddingLeft.value+paddingRight.value+textStyle.textPaddingLeft.value+textStyle.textPaddingRight.value;
    }
}

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    CGFloat measuredHeight = MAX(string.size.height+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value, checkHeight.value);

    if (measuredHeight > maxHeight) {
        height.value = maxHeight+paddingTop.value+paddingBottom.value+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value;
    } else {
        height.value = measuredHeight+paddingTop.value+paddingBottom.value;
    }
}

@end
