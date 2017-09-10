#import "AGEditableText.h"
#import "AGTextField.h"

@interface AGTextInput : AGEditableText <UITextFieldDelegate>{
    AGTextField *textInput;
}

@end
