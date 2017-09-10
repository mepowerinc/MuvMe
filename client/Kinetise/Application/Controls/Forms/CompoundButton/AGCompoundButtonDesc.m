#import "AGCompoundButtonDesc.h"
#import "AGActionManager.h"

@implementation AGCompoundButtonDesc

@synthesize form;
@synthesize checkWidth;
@synthesize checkHeight;
@synthesize innerSpace;
@synthesize checkValign;

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
    form.value = @([[form.initialValue.value lowercaseString] isEqualToString:@"true"]);
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGCompoundButtonDesc *obj = [super copyWithZone:zone];
    
    obj.form = [[form copy] autorelease];
    obj.checkWidth = checkWidth;
    obj.checkHeight = checkHeight;
    obj.innerSpace = innerSpace;
    obj.checkValign = checkValign;
    
    return obj;
}

@end
