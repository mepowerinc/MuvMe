#import "AGDescriptorProtocol.h"
#import "AGControlDesc.h"
#import "AGFeedClientProtocol.h"

@interface AGAdapterLayout : UICollectionViewLayout <AGDescriptorProtocol>{
    AGControlDesc<AGFeedClientProtocol> *descriptor;
}
@property(nonatomic, retain) AGControlDesc<AGFeedClientProtocol> *descriptor;

@end
