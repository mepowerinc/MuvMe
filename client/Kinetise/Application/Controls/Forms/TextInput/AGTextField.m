#import "AGTextField.h"

@implementation AGTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5, 0);
}

@end
