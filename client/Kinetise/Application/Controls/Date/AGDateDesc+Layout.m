#import "AGDateDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"
#import "AGApplication.h"

@implementation AGDateDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    // font size
    if (textStyle.useTextMultiplier) {
        textStyle.fontSize = AGSizeWithSize(textStyle.fontSize, [AGLAYOUTMANAGER KPXToPixels:textStyle.fontSize.valueInUnits]*AGAPPLICATION.textMultiplier);
    } else {
        textStyle.fontSize = AGSizeWithSize(textStyle.fontSize, [AGLAYOUTMANAGER KPXToPixels:textStyle.fontSize.valueInUnits]);
    }

    // text
    dateFormatter.dateFormat = dateFormat;
    NSString *widestDateString = [dateFormatter widestDateStringWithFont:AG_FONT_NAME andSize:textStyle.fontSize.value andBold:textStyle.isBold andItalic:textStyle.isItalic];
    string.fontSize = textStyle.fontSize.value;
    string.string = widestDateString;
}

@end
