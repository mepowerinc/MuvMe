#import "AGRadioButton.h"
#import "AGContainer.h"
#import "AGFormClientProtocol.h"
#import "AGRadioButtonDesc.h"

@implementation AGRadioButton

#pragma mark - Touches

- (void)onTap:(CGPoint)point {
    AGRadioButtonDesc *desc = (AGRadioButtonDesc *)descriptor;

    if ([parent conformsToProtocol:@protocol(AGFormProtocol)]) {
        id<AGFormProtocol> formParent = (id<AGFormProtocol>)parent;
        [formParent setValue:desc.value];
    }

    [super onTap:point];
}

@end
