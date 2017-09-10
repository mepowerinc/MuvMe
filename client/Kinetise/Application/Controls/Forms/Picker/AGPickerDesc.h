#import "AGButtonDesc.h"
#import "AGFormClientProtocol.h"

@interface AGPickerDesc : AGButtonDesc <AGFormClientProtocol>{
    AGForm *form;
    AGVariable *iconSrc;
    AGVariable *iconActiveSrc;
    AGSizeModeType iconSizeMode;
    AGSize iconWidth;
    AGSize iconHeight;
    AGAlignType iconAlign;
    AGValignType iconValign;
}

@property(nonatomic, retain) AGVariable *iconSrc;
@property(nonatomic, retain) AGVariable *iconActiveSrc;
@property(nonatomic, assign) AGSizeModeType iconSizeMode;
@property(nonatomic, assign) AGSize iconWidth;
@property(nonatomic, assign) AGSize iconHeight;
@property(nonatomic, assign) AGAlignType iconAlign;
@property(nonatomic, assign) AGValignType iconValign;

@end
