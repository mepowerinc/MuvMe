#import "AGRadioGroup.h"
#import "AGRadioGroupDesc.h"
#import "AGRadioButton.h"
#import "AGRadioButtonDesc.h"

@implementation AGRadioGroup

#pragma mark - Form

- (void)setValue:(NSString *)value_ {
    AGRadioGroupDesc *desc = (AGRadioGroupDesc *)descriptor;

    for (AGRadioButton *control in self.controls) {
        if ([control isKindOfClass:[AGRadioButton class]]) {
            AGRadioButtonDesc *controlDesc = (AGRadioButtonDesc *)control.descriptor;
            if ([controlDesc.value isEqualToString:value_]) {
                control.selected = YES;

                // form
                desc.form.value = controlDesc.value;
            } else {
                control.selected = NO;
            }
        }
    }

    // validate
    if (![desc.form isValid:desc.form.value]) {
        [self validate];
    } else {
        [self invalidate];
    }
}

#pragma mark - Reset

- (void)reset {
    // reset radio buttons
    for (AGRadioButton *control in self.controls) {
        if ([control isKindOfClass:[AGRadioButton class]]) {
            [control reset];
        }
    }

    // invalidate
    [self invalidate];
}

@end
