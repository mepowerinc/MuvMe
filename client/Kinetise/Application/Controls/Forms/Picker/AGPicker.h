#import "AGButton.h"
#import "AGFormProtocol.h"

@interface AGPicker : AGButton <AGFormProtocol>{
    AGImageView *iconView;
    AGImageAsset *iconAsset;
    AGImageAsset *iconActiveAsset;
}

@end
