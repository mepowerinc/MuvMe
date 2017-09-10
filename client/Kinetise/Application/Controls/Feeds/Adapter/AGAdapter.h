#import "AGDescriptorProtocol.h"
#import "AGAdapterLayout.h"
#import "AGControlDesc.h"
#import "AGFeedClientProtocol.h"
#import "AGAdapterCell.h"

@interface AGAdapter : UICollectionView <AGDescriptorProtocol>{
    AGControlDesc<AGFeedClientProtocol> *descriptor;
}
@property(nonatomic, retain) AGControlDesc<AGFeedClientProtocol> *descriptor;

- (Class)cellClass;
- (Class)layoutClass;
- (void)setupAssets;
- (void)loadAssets;

@end
