#import "AGEditableTextDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"
#import "AGFontManager.h"

@implementation AGEditableTextDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    // font size
    textStyle.fontSize = AGSizeWithSize(textStyle.fontSize, [AGLAYOUTMANAGER KPXToPixels:textStyle.fontSize.valueInUnits]);
    
    // icon
    if( iconSrc ) {
        iconWidth.value = [AGLAYOUTMANAGER KPXToPixels:iconWidth.valueInUnits];
        iconHeight.value = [AGLAYOUTMANAGER KPXToPixels:iconHeight.valueInUnits];
    }
}

#pragma mark - Measure

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    UIFont *font = [AGFONTMANAGER fontWithSize:textStyle.fontSize.value bold:textStyle.isBold italic:textStyle.isItalic];
    CGFloat oneLineHeight = [@"ÓAy" sizeWithAttributes:@{NSFontAttributeName:font}].height*AG_TEXT_PADDING;
    CGFloat measuredHeight = MAX(oneLineHeight+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value, iconHeight.value);
    
    if (measuredHeight > maxHeight) {
        height.value = maxHeight+paddingTop.value+paddingBottom.value+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value;
    } else {
        height.value = measuredHeight+paddingTop.value+paddingBottom.value;
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
