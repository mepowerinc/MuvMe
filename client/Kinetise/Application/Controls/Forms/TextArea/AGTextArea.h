#import "AGEditableText.h"
#import "AGTextView.h"

@interface AGTextArea : AGEditableText <UITextViewDelegate>{
    AGTextView *textInput;
}

@end
