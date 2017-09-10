#import "AGSignatureDesc+Layout.h"
#import "AGLayoutManager.h"
#import "AGControlDesc+Layout.h"

@implementation AGSignatureDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    // stroke width
    strokeWidth.value = [AGLAYOUTMANAGER KPXToPixels:strokeWidth.valueInUnits];

    // clear size
    clearSize.value = [AGLAYOUTMANAGER KPXToPixels:clearSize.valueInUnits];

    // clear margin
    clearMargin.value = [AGLAYOUTMANAGER KPXToPixels:clearMargin.valueInUnits];
}

@end
