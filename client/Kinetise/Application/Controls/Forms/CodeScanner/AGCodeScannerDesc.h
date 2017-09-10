#import "AGButtonDesc.h"
#import "AGFormClientProtocol.h"

@interface AGCodeScannerDesc : AGButtonDesc <AGFormClientProtocol>{
    AGForm *form;
    AGCodeType codeType;
}

@property(nonatomic, assign) AGCodeType codeType;
@end
