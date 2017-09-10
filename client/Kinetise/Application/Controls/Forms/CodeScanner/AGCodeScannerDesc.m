#import "AGCodeScannerDesc.h"
#import "AGActionManager.h"

@implementation AGCodeScannerDesc

@synthesize form;
@synthesize codeType;

#pragma mark - Initialization

- (void)dealloc {
    self.form = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // code type
    codeType = AGCodeTypeNone;

    return self;
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
    AGCodeScannerDesc *obj = [super copyWithZone:zone];

    obj.form = [[form copy] autorelease];
    obj.codeType = codeType;

    return obj;
}

@end
