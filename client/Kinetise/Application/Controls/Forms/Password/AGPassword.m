#import "AGPassword.h"
#import "AGPasswordDesc.h"
#import "AGApplication.h"

@implementation AGPassword

#pragma mark - Initialization

- (id)initWithDesc:(AGPasswordDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // text input
    textInput.secureTextEntry = YES;
    textInput.clearsOnBeginEditing = YES;
    
    return self;
}

@end
