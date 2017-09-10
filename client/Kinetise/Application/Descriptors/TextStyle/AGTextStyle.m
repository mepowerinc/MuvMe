#import "AGTextStyle.h"

@implementation AGTextStyle

@synthesize fontSize;
@synthesize useTextMultiplier;
@synthesize isBold;
@synthesize isItalic;
@synthesize isUnderline;
@synthesize textAlign;
@synthesize textValign;
@synthesize textColor;
@synthesize textActiveColor;
@synthesize textInvalidColor;
@synthesize watermarkColor;
@synthesize textPaddingLeft;
@synthesize textPaddingRight;
@synthesize textPaddingTop;
@synthesize textPaddingBottom;

- (id)copyWithZone:(NSZone *)zone {
    AGTextStyle *obj = [[[self class] allocWithZone:zone] init];
    
    obj.fontSize = fontSize;
    obj.useTextMultiplier = useTextMultiplier;
    obj.isBold = isBold;
    obj.isItalic = isItalic;
    obj.isUnderline = isUnderline;
    obj.textAlign = textAlign;
    obj.textValign = textValign;
    obj.textColor = textColor;
    obj.textActiveColor = textActiveColor;
    obj.textInvalidColor = textInvalidColor;
    obj.watermarkColor = watermarkColor;
    obj.textPaddingLeft = textPaddingLeft;
    obj.textPaddingRight = textPaddingRight;
    obj.textPaddingTop = textPaddingTop;
    obj.textPaddingBottom = textPaddingBottom;
    
    return obj;
}

@end
