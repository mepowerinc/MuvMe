#import "AGGalleryDesc+Layout.h"
#import "AGControlDesc+Layout.h"

@implementation AGGalleryDesc (Layout)

#pragma mark - Layout

- (void)prepareLayout {
    for (AGControlDesc *child in galleryElements) {
        [child prepareLayout];
    }
}

- (void)layout {
    for (AGControlDesc *child in galleryElements) {
        [child layout];
    }
}

#pragma mark - Measure

- (void)measureBlockWidth:(CGFloat)maxWidth withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockWidth:maxWidth withSpaceForMax:maxSpaceForMax];

    for (AGControlDesc *child in galleryElements) {
        [child measureBlockWidth:self.viewportWidth withSpaceForMax:self.viewportWidth];
    }
}

- (void)measureBlockHeight:(CGFloat)maxHeight withSpaceForMax:(CGFloat)maxSpaceForMax {
    [super measureBlockHeight:maxHeight withSpaceForMax:maxSpaceForMax];

    for (AGControlDesc *child in galleryElements) {
        [child measureBlockHeight:self.viewportHeight withSpaceForMax:self.viewportHeight];
    }
}

@end
