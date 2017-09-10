#import "AGSignatureDesc.h"
#import "AGActionManager.h"

@implementation AGSignatureDesc

@synthesize strokeWidth;
@synthesize strokeColor;
@synthesize clearSrc;
@synthesize clearActiveSrc;
@synthesize clearSize;
@synthesize clearMargin;

#pragma mark - Initialization

@synthesize form;

- (void)dealloc {
    self.form = nil;
    self.clearSrc = nil;
    self.clearActiveSrc = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.clearMargin = AGSizeMake(20, unitKpx);

    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];

    // clear src
    [AGACTIONMANAGER executeVariable:clearSrc withSender:self];
    [AGACTIONMANAGER executeVariable:clearActiveSrc withSender:self];

    // form
    [form executeVariables:self];

    // initial value
    form.value = nil;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGSignatureDesc *obj = [super copyWithZone:zone];

    obj.form = [[form copy] autorelease];
    obj.strokeWidth = strokeWidth;
    obj.strokeColor = strokeColor;
    obj.clearSrc = [[clearSrc copy] autorelease];
    obj.clearActiveSrc = [[clearActiveSrc copy] autorelease];
    obj.clearSize = clearSize;
    obj.clearMargin = clearMargin;

    return obj;
}

@end
