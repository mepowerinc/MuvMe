#import "AGPickerDesc.h"
#import "AGActionManager.h"
#import "NSObject+Nil.h"

@implementation AGPickerDesc

@synthesize form;
@synthesize iconSrc;
@synthesize iconActiveSrc;
@synthesize iconSizeMode;
@synthesize iconWidth;
@synthesize iconHeight;
@synthesize iconAlign;
@synthesize iconValign;

#pragma mark - Initialization

- (void)dealloc {
    self.form = nil;
    self.iconSrc = nil;
    self.iconActiveSrc = nil;
    [super dealloc];
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
    
    // icon
    [AGACTIONMANAGER executeVariable:iconSrc withSender:self];
    [AGACTIONMANAGER executeVariable:iconActiveSrc withSender:self];
    
    // form
    [form executeVariables:self];
    
    // initial value
    if (isNotEmpty(form.initialValue.value) ) {
        form.value = form.initialValue.value;
    } else {
        form.initialValue.value = nil;
        form.value = nil;
    }
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGPickerDesc *obj = [super copyWithZone:zone];
    
    obj.form = [[form copy] autorelease];
    obj.iconSrc = [[iconSrc copy] autorelease];
    obj.iconActiveSrc = [[iconActiveSrc copy] autorelease];
    obj.iconSizeMode = iconSizeMode;
    obj.iconWidth = iconWidth;
    obj.iconHeight = iconHeight;
    obj.iconAlign = iconAlign;
    obj.iconValign = iconValign;
    
    return obj;
}

@end
