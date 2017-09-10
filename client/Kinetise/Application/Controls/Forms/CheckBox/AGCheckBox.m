#import "AGCheckBox.h"
#import "AGCheckBoxDesc.h"

@implementation AGCheckBox

#pragma mark - Touches

- (void)onTap:(CGPoint)point {
    self.selected = !self.isSelected;

    [super onTap:point];
}

@end
