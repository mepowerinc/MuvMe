#import "AGControlDesc.h"
#import "AGFormClientProtocol.h"
#import "AGTextStyle.h"

@interface AGEditableTextDesc : AGControlDesc <AGFormClientProtocol>{
    AGForm *form;
    AGVariable *watermark;
    AGTextStyle *textStyle;
    AGKeyboardType keyboardType;
    AGAction *onAccept;
    AGVariable *iconSrc;
    AGSizeModeType iconSizeMode;
    AGSize iconWidth;
    AGSize iconHeight;
    AGAlignType iconAlign;
    AGValignType iconValign;
}

@property(nonatomic, retain) AGVariable *watermark;
@property(nonatomic, retain) AGTextStyle *textStyle;
@property(nonatomic, assign) AGKeyboardType keyboardType;
@property(nonatomic, retain) AGAction *onAccept;
@property(nonatomic, retain) AGVariable *iconSrc;
@property(nonatomic, assign) AGSizeModeType iconSizeMode;
@property(nonatomic, assign) AGSize iconWidth;
@property(nonatomic, assign) AGSize iconHeight;
@property(nonatomic, assign) AGAlignType iconAlign;
@property(nonatomic, assign) AGValignType iconValign;

@end
