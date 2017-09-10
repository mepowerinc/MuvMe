#import "AGControl.h"
#import "AGFormProtocol.h"

@interface AGSignature : AGControl <AGFormProtocol>{
    UIButton *clearButton;
    AGImageAsset *clearSource;
    AGImageAsset *clearActiveSource;
}

@end
