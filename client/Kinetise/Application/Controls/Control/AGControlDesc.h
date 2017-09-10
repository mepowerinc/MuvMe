#import "AGDesc.h"
#import "AGVariable.h"
#import "AGAction.h"

@class AGSectionDesc;

@interface AGControlDesc : AGDesc <NSCopying>{
    NSString *identifier;
    NSString *reuseIdentifier;
    NSInteger itemIndex;
    AGSize width;
    AGSize height;
    AGSize marginLeft;
    AGSize marginRight;
    AGSize marginTop;
    AGSize marginBottom;
    AGSize paddingLeft;
    AGSize paddingRight;
    AGSize paddingTop;
    AGSize paddingBottom;
    AGSize radiusTopLeft;
    AGSize radiusTopRight;
    AGSize radiusBottomLeft;
    AGSize radiusBottomRight;
    AGAlignType align;
    AGValignType valign;
    AGSize borderLeft;
    AGSize borderRight;
    AGSize borderTop;
    AGSize borderBottom;
    AGColor borderColor;
    AGColor invalidBorderColor;
    AGVariable *background;
    AGColor backgroundColor;
    AGSizeModeType backgroundSizeMode;
    AGControlDesc *parent;
    AGSectionDesc *section;
    CGFloat positionX;
    CGFloat positionY;
    CGFloat integralPositionX;
    CGFloat integralPositionY;
    CGFloat globalPositionX;
    CGFloat globalPositionY;
    CGFloat globalIntegralPositionX;
    CGFloat globalIntegralPositionY;
    CGFloat blockWidth;
    CGFloat blockHeight;
    CGFloat viewportWidth;
    CGFloat viewportHeight;
    AGVariable *excludeFromCalculateVar;
    AGVariable *hiddenVar;
    BOOL excludeFromCalculate;
    BOOL hidden;
    AGAction *onClickAction;
    AGAction *onSwipeLeftAction;
    AGAction *onSwipeRightAction;
    AGAction *onChangeAction;
    AGAction *onUpdateAction;
    AGAction *onEndEditing;
    CGFloat maxBlockWidth;
    CGFloat maxBlockWidthForMax;
    CGFloat maxBlockHeight;
    CGFloat maxBlockHeightForMax;
}

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *reuseIdentifier;
@property(nonatomic, assign) NSInteger itemIndex;

@property(nonatomic, assign) AGSize width;
@property(nonatomic, assign) AGSize height;
@property(nonatomic, assign) AGSize marginLeft;
@property(nonatomic, assign) AGSize marginRight;
@property(nonatomic, assign) AGSize marginTop;
@property(nonatomic, assign) AGSize marginBottom;
@property(nonatomic, assign) AGSize paddingLeft;
@property(nonatomic, assign) AGSize paddingRight;
@property(nonatomic, assign) AGSize paddingTop;
@property(nonatomic, assign) AGSize paddingBottom;
@property(nonatomic, assign) AGSize radiusTopLeft;
@property(nonatomic, assign) AGSize radiusTopRight;
@property(nonatomic, assign) AGSize radiusBottomLeft;
@property(nonatomic, assign) AGSize radiusBottomRight;

@property(nonatomic, assign) AGAlignType align;
@property(nonatomic, assign) AGValignType valign;

@property(nonatomic, assign) AGSize borderLeft;
@property(nonatomic, assign) AGSize borderRight;
@property(nonatomic, assign) AGSize borderTop;
@property(nonatomic, assign) AGSize borderBottom;
@property(nonatomic, assign) AGColor borderColor;
@property(nonatomic, assign) AGColor invalidBorderColor;

@property(nonatomic, retain) AGVariable *background;
@property(nonatomic, assign) AGColor backgroundColor;
@property(nonatomic, assign) AGSizeModeType backgroundSizeMode;

@property(nonatomic, assign) AGControlDesc *parent;
@property(nonatomic, assign) AGSectionDesc *section;

@property(nonatomic, assign) CGFloat positionX;
@property(nonatomic, assign) CGFloat positionY;
@property(nonatomic, assign) CGFloat integralPositionX;
@property(nonatomic, assign) CGFloat integralPositionY;
@property(nonatomic, assign) CGFloat globalPositionX;
@property(nonatomic, assign) CGFloat globalPositionY;
@property(nonatomic, assign) CGFloat globalIntegralPositionX;
@property(nonatomic, assign) CGFloat globalIntegralPositionY;
@property(nonatomic, readonly) CGFloat blockWidth;
@property(nonatomic, readonly) CGFloat blockHeight;
@property(nonatomic, readonly) CGFloat viewportWidth;
@property(nonatomic, readonly) CGFloat viewportHeight;

@property(nonatomic, retain) AGVariable *excludeFromCalculateVar;
@property(nonatomic, retain) AGVariable *hiddenVar;
@property(nonatomic, assign) BOOL excludeFromCalculate;
@property(nonatomic, assign) BOOL hidden;

@property(nonatomic, retain) AGAction *onClickAction;
@property(nonatomic, retain) AGAction *onSwipeLeftAction;
@property(nonatomic, retain) AGAction *onSwipeRightAction;
@property(nonatomic, retain) AGAction *onChangeAction;
@property(nonatomic, retain) AGAction *onUpdateAction;
@property(nonatomic, retain) AGAction *onEndEditing;

@property(nonatomic, readonly) CGFloat maxBlockWidth;
@property(nonatomic, readonly) CGFloat maxBlockWidthForMax;
@property(nonatomic, readonly) CGFloat maxBlockHeight;
@property(nonatomic, readonly) CGFloat maxBlockHeightForMax;

- (NSString *)fullPath:(NSString *)relativePath;

@end
