#import "AGControlDesc.h"
#import "AGFormClientProtocol.h"

@interface AGSignatureDesc : AGControlDesc <AGFormClientProtocol>{
    AGForm *form;
    AGSize strokeWidth;
    AGColor strokeColor;
    AGVariable *clearSrc;
    AGVariable *clearActiveSrc;
    AGSize clearSize;
    AGSize clearMargin;
}

@property(nonatomic, assign) AGSize strokeWidth;
@property(nonatomic, assign) AGColor strokeColor;
@property(nonatomic, retain) AGVariable *clearSrc;
@property(nonatomic, retain) AGVariable *clearActiveSrc;
@property(nonatomic, assign) AGSize clearSize;
@property(nonatomic, assign) AGSize clearMargin;

@end
