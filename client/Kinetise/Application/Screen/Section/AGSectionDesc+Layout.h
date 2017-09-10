#import "AGSectionDesc.h"
#import "AGLayoutProtocol.h"

@interface AGSectionDesc (Layout) <AGLayoutProtocol>

- (void)layoutChildren;

@end
