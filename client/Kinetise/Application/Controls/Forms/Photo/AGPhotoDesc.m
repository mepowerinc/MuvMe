#import "AGPhotoDesc.h"
#import "AGActionManager.h"

@implementation AGPhotoDesc

#pragma mark - Initialization

@synthesize form;

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
    form.value = nil;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGPhotoDesc *obj = [super copyWithZone:zone];

    obj.form = [[form copy] autorelease];

    return obj;
}

@end
