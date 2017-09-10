#import "AGControl.h"
#import "AGFormProtocol.h"
#import "AGImageView.h"

@interface AGEditableText : AGControl <AGFormProtocol>{
    NSDictionary *textAttributes;
    NSDictionary *invalidAttributes;
    NSDictionary *placeholderAttributes;
    AGImageView *iconView;
    AGImageAsset *iconAsset;
}

@property(nonatomic, retain) NSDictionary *textAttributes;
@property(nonatomic, retain) NSDictionary *invalidAttributes;
@property(nonatomic, retain) NSDictionary *placeholderAttributes;
@property(nonatomic, readonly) UIView<UITextInputTraits> *textInput;

- (void)onEditingWillBegin;
- (void)onEditingBegin;
- (void)onEditingEnd;
- (void)onEditingChange;
- (BOOL)onNext;

@end
