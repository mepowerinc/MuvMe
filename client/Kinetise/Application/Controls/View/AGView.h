#import "AGDescriptorProtocol.h"
#import "AGLayer.h"
#import "AGDesc.h"
#import "NSString+UriEncoding.h"

@interface AGView : UIView <AGDescriptorProtocol>{
    AGDesc *descriptor;
}

@property(nonatomic, readonly) AGLayer *layer;
@property(nonatomic, retain) AGDesc *descriptor;

- (void)setupAssets;
- (void)loadAssets;
- (void)update;

@end
