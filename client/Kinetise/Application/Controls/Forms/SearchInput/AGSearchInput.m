#import "AGSearchInput.h"
#import "AGSearchInputDesc.h"
#import "AGActionManager.h"

@implementation AGSearchInput

#pragma mark - Initialization

- (id)initWithDesc:(AGSearchInputDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // return key type
    textInput.returnKeyType = UIReturnKeySearch;
    
    return self;
}

#pragma mark - Lifecycle

- (void)onEditingWillBegin {
    // return key type
    textInput.returnKeyType = UIReturnKeySearch;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField_ {
    AGSearchInputDesc *desc = (AGSearchInputDesc *)descriptor;
    
    // resign responder
    [textInput resignFirstResponder];
    
    // on accept
    if (desc.onAccept) {
        [AGACTIONMANAGER executeAction:desc.onAccept withSender:desc];
    }
    
    return YES;
}

@end
