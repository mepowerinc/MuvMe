#import "AGPresenterDesc.h"
#import "AGControlDesc.h"

@interface AGPopupDesc : AGPresenterDesc {
    AGControlDesc *controlDesc;
}

@property(nonatomic, retain) AGControlDesc *controlDesc;

@end
