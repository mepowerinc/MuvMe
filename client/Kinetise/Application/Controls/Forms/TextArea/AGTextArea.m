#import "AGTextArea.h"
#import "AGTextAreaDesc.h"
#import "AGApplication.h"

@implementation AGTextArea

@synthesize textInput;

#pragma mark - Initialization

- (id)initWithDesc:(AGTextAreaDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // text input
    textInput.typingAttributes = textAttributes;

    // value
    [self setValue:descriptor_.form.value ];

    // text input
    textInput.delegate = self;

    return self;
}

- (AGTextView *)textInput {
    if (!textInput) {
        textInput = [[AGTextView alloc] initWithFrame:CGRectZero];
        [contentView addSubview:textInput];
        [textInput release];
    }
    
    return textInput;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGTextAreaDesc *)descriptor_ {
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
    AGTextAreaDesc *desc = (AGTextAreaDesc *)descriptor;

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
        textInput.typingAttributes = invalidAttributes;
    } else {
        textInput.typingAttributes = textAttributes;
    }

    // !!! needed to rerender text with new attributes
    textInput.text = textInput.text;
}

#pragma mark - Assets

- (void)loadAssets {
    [super loadAssets];

    AGTextAreaDesc *desc = (AGTextAreaDesc *)descriptor;

    // watermark
    textInput.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:desc.watermark.value attributes:placeholderAttributes] autorelease];
}

#pragma mark - Reset

- (void)reset {
    AGTextAreaDesc *desc = (AGTextAreaDesc *)descriptor;

    // value
    [self setValue:desc.form.value ];

    // resign first responder
    [textInput resignFirstResponder];
}

#pragma mark - Editing

- (void)onEditingChange {
    // value
    [self setValue:textInput.text ];

    [super onEditingChange];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView_ {
    [self onEditingWillBegin];

    return YES;
}

- (BOOL)textView:(UITextView *)textView_ shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];

    if ([text length] == 1 && resultRange.location != NSNotFound) {
        if ([self onNext]) {
            return NO;
        } else {
            [textInput resignFirstResponder];
            return YES;
        }
    }

    return YES;
}

@end
