#import "AGHyperlink.h"
#import "AGHyperlinkDesc.h"

@implementation AGHyperlink

#pragma mark - Touches

- (void)onTouchBegan:(CGPoint)point {
    AGHyperlinkDesc *desc = (AGHyperlinkDesc *)descriptor;

    // label
    desc.string.color = desc.textStyle.textActiveColor;
    label.string = desc.string;

    [super onTouchBegan:point];
}

- (void)onTouchMoved:(CGPoint)point {
    AGHyperlinkDesc *desc = (AGHyperlinkDesc *)descriptor;

    // label
    if (![self pointInside:point withEvent:nil]) {
        desc.string.color = desc.textStyle.textColor;
    } else {
        desc.string.color = desc.textStyle.textActiveColor;
    }
    label.string = desc.string;

    [super onTouchMoved:point];
}

- (void)onTouchEnded:(CGPoint)point {
    AGHyperlinkDesc *desc = (AGHyperlinkDesc *)descriptor;

    // label
    desc.string.color = desc.textStyle.textColor;
    label.string = desc.string;

    [super onTouchEnded:point];
}

- (void)onTouchCancelled:(CGPoint)point {
    AGHyperlinkDesc *desc = (AGHyperlinkDesc *)descriptor;

    // label
    desc.string.color = desc.textStyle.textColor;
    label.string = desc.string;

    [super onTouchCancelled:point];
}

@end
