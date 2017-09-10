#import "AGControlDesc.h"
#import "AGLayoutProtocol.h"

@interface AGControlDesc (Layout) <AGLayoutProtocol>

- (void)measurePaddingLeft;
- (void)measurePaddingRight;
- (void)measurePaddingTop;
- (void)measurePaddingBottom;

@end
