#import "AGTextInput.h"
#import "AGTextInputDesc.h"
#import "AGApplication.h"
#import "AGActionManager.h"

@implementation AGTextInput

@synthesize textInput;

#pragma mark - Initialization

- (id)initWithDesc:(AGTextInputDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // text input
    textInput.defaultTextAttributes = textAttributes;
    
    // value
    [self setValue:descriptor_.form.value ];
    
    // text input
    textInput.delegate = self;
    
    return self;
}

- (AGTextField *)textInput {
    if (!textInput) {
        textInput = [[AGTextField alloc] initWithFrame:CGRectZero];
        [contentView addSubview:textInput];
        [textInput release];
    }
    
    return textInput;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGTextInputDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }
    
    // value
    [self setValue:descriptor_.form.value ];
}

#pragma mark - Form

- (void)setValue:(NSString *)value_ {
    AGTextInputDesc *desc = (AGTextInputDesc *)descriptor;
    
    // state
    self.filled = (value_.length > 0);
    
    // form
    desc.form.value = value_;
    
    // text input
    textInput.text = value_;
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];
    
    // text input
    if (self.isInvalid) {
        textInput.defaultTextAttributes = invalidAttributes;
    } else {
        textInput.defaultTextAttributes = textAttributes;
    }
}

#pragma mark - Assets

- (void)loadAssets {
    [super loadAssets];
    
    AGTextInputDesc *desc = (AGTextInputDesc *)descriptor;
    
    // watermark
    textInput.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:desc.watermark.value attributes:placeholderAttributes] autorelease];
}

#pragma mark - Reset

- (void)reset {
    AGTextInputDesc *desc = (AGTextInputDesc *)descriptor;
    
    // value
    [self setValue:desc.form.value ];
    
    // resign first responder
    [textInput resignFirstResponder];
}

#pragma mark - Editing

- (void)onEditingChange {
    // value
    [self setValue:textInput.text];
    
    [super onEditingChange];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField_ {
    AGTextInputDesc *desc = (AGTextInputDesc *)descriptor;
    
    if ([self onNext]) {
        return NO;
    } else {
        // on accept
        if (desc.onAccept) {
            [AGACTIONMANAGER executeAction:desc.onAccept withSender:desc];
        }
        
        // resign responder
        [textInput resignFirstResponder];
        
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField_ {
    [self onEditingWillBegin];
    
    return YES;
}

@end
