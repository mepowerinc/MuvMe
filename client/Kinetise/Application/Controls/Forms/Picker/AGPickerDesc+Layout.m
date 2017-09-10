#import "AGPickerDesc+Layout.h"
#import "AGControlDesc+Layout.h"
#import "AGLayoutManager.h"

@implementation AGPickerDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    [super prepareLayout];
    
    // icon
    if (iconSrc) {
        iconWidth.value = [AGLAYOUTMANAGER KPXToPixels:iconWidth.valueInUnits];
        iconHeight.value = [AGLAYOUTMANAGER KPXToPixels:iconHeight.valueInUnits];
    }
}

@end
