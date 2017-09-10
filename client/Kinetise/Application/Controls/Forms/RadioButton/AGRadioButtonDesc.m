#import "AGRadioButtonDesc.h"

@implementation AGRadioButtonDesc

@synthesize value;

- (void)dealloc {
    self.value = value;
    [super dealloc];
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGRadioButtonDesc *obj = [super copyWithZone:zone];

    obj.value = value;

    return obj;
}

@end
