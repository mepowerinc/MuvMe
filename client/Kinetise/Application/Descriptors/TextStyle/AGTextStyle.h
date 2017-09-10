#import "AGUnits.h"
#import "AGVariable.h"

@interface AGTextStyle : NSObject {
    AGSize fontSize;
    BOOL useTextMultiplier;
    BOOL isBold;
    BOOL isItalic;
    BOOL isUnderline;
    AGAlignType textAlign;
    AGValignType textValign;
    AGColor textColor;
    AGColor textActiveColor;
    AGColor textInvalidColor;
    AGColor watermarkColor;
    AGSize textPaddingLeft;
    AGSize textPaddingRight;
    AGSize textPaddingTop;
    AGSize textPaddingBottom;
}

@property(nonatomic, assign) AGSize fontSize;
@property(nonatomic, assign) BOOL useTextMultiplier;
@property(nonatomic, assign) BOOL isBold;
@property(nonatomic, assign) BOOL isItalic;
@property(nonatomic, assign) BOOL isUnderline;
@property(nonatomic, assign) AGAlignType textAlign;
@property(nonatomic, assign) AGValignType textValign;
@property(nonatomic, assign) AGColor textColor;
@property(nonatomic, assign) AGColor textActiveColor;
@property(nonatomic, assign) AGColor textInvalidColor;
@property(nonatomic, assign) AGColor watermarkColor;
@property(nonatomic, assign) AGSize textPaddingLeft;
@property(nonatomic, assign) AGSize textPaddingRight;
@property(nonatomic, assign) AGSize textPaddingTop;
@property(nonatomic, assign) AGSize textPaddingBottom;

@end
