#import "AGButtonDesc.h"
#import "AGFormClientProtocol.h"

@interface AGPhotoDesc : AGButtonDesc <AGFormClientProtocol>{
    AGForm *form;
}

@end
