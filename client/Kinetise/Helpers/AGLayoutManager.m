#import "AGLayoutManager.h"
#import "AGApplication.h"
#import "DescriptorsHeader.h"
#import "AGDesc+Layout.h"
#import "AGScreenDesc+Layout.h"

@implementation AGLayoutManager

@synthesize screenSize;
@synthesize screenShorterSide;
@synthesize screenLongerSide;
@synthesize screenScale;
@synthesize invScreenScale;

SINGLETON_IMPLEMENTATION(AGLayoutManager)

- (id)init {
    self = [super init];

    // screen data
    screenScale = [UIScreen mainScreen].scale;
    invScreenScale = 1.0/screenScale;

    return self;
}

- (void)layout:(id<AGLayoutProtocol>)desc {
    if ([desc isKindOfClass:[AGPresenterDesc class]]) {
        [self layout:desc withSize:screenSize];
    } else if ([desc isKindOfClass:[AGSectionDesc class]]) {
        AGSectionDesc *sectionDesc = (AGSectionDesc *)desc;

        [desc prepareLayout];
        [desc measureBlockWidth:sectionDesc.maxBlockWidth withSpaceForMax:sectionDesc.maxBlockWidthForMax];
        [desc measureBlockHeight:sectionDesc.maxBlockHeight withSpaceForMax:sectionDesc.maxBlockHeightForMax];
        [desc layout];
    } else if ([desc isKindOfClass:[AGControlDesc class]]) {
        AGControlDesc *controlDesc = (AGControlDesc *)desc;

        [desc prepareLayout];
        [desc measureBlockWidth:controlDesc.maxBlockWidth withSpaceForMax:controlDesc.maxBlockWidthForMax];
        [desc measureBlockHeight:controlDesc.maxBlockHeight withSpaceForMax:controlDesc.maxBlockHeightForMax];
        [desc layout];
    }
}

- (void)layout:(id<AGLayoutProtocol>)desc withSize:(CGSize)size {
    screenSize = size;
    screenShorterSide = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    screenLongerSide = screenSize.width > screenSize.height ? screenSize.width : screenSize.height;

    [desc prepareLayout];
    [desc measureBlockWidth:size.width withSpaceForMax:size.width];
    [desc measureBlockHeight:size.height withSpaceForMax:size.height];
    [desc layout];
}

- (CGFloat)KPXToPixels:(NSInteger)kpx {
    return kpx*(SCREEN_SHORTER_SIDE*AG_KPX_SCALE);
}

- (CGFloat)percentToPixels:(NSInteger)percent withValue:(CGFloat)value {
    return (percent*value)/100.0;
}

@end
