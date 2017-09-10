#import "AGRadioGroupDesc.h"
#import "AGRadioButtonDesc.h"
#import "AGActionManager.h"

@implementation AGRadioGroupDesc

@synthesize form;

#pragma mark - Initialization

- (void)dealloc {
    self.form = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    // form
    [form executeVariables:self];

    // initial value
    form.value = form.initialValue.value;

    // select radio button
    BOOL hasChoice = NO;
    for (AGRadioButtonDesc *child in self.children) {
        if ([child isKindOfClass:[AGRadioButtonDesc class]]) {
            if ([child.value isEqualToString:form.value]) {
                child.form.value = @(YES);
                hasChoice = YES;
            } else {
                child.form.value = @(NO);
            }
        }
    }

    if (!hasChoice && self.children.count) {
        AGRadioButtonDesc *child = self.children[0];
        child.form.value = @(YES);
        form.value = child.value;
    }
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGRadioGroupDesc *obj = [super copyWithZone:zone];

    obj.form = [[form copy] autorelease];

    return obj;
}

@end
