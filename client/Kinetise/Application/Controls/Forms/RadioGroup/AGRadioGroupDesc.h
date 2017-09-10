#import "AGContainerDesc.h"
#import "AGFormClientProtocol.h"

@interface AGRadioGroupDesc : AGContainerDesc <AGFormClientProtocol>{
    AGForm *form;
}

@end
