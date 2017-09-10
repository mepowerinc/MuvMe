#import "AGTextAreaDesc+Layout.h"
#import "AGEditableTextDesc+Layout.h"
#import "AGFontManager.h"

@implementation AGTextAreaDesc (Layout)

#pragma mark - Measure

- (void)measureHeightForMin:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    UIFont *font = [AGFONTMANAGER fontWithSize:textStyle.fontSize.value bold:textStyle.isBold italic:textStyle.isItalic];
    CGFloat oneLineHeight = [@"ÓAy" sizeWithAttributes:@{NSFontAttributeName:font}].height*AG_TEXT_PADDING;
    CGFloat measuredHeight = MAX(rows*oneLineHeight+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value, iconHeight.value);
    
    if (measuredHeight > maxHeight) {
        height.value = maxHeight+paddingTop.value+paddingBottom.value+textStyle.textPaddingTop.value+textStyle.textPaddingBottom.value;
    } else {
        height.value = measuredHeight+paddingTop.value+paddingBottom.value;
    }
}

@end
