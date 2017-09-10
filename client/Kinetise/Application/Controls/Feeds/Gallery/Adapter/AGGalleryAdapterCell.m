#import "AGGalleryAdapterCell.h"

@implementation AGGalleryAdapterCell

- (void)layoutSubviews {
    [super layoutSubviews];

    AGControlDesc *desc = (AGControlDesc *)control.descriptor;

    control.frame = CGRectMake(AG_GALLERY_DETAIL_PADDING,
                               0,
                               MAX(desc.width.value+desc.borderLeft.value+desc.borderRight.value, 0),
                               MAX(desc.height.value+desc.borderTop.value+desc.borderBottom.value, 0));

    [control setNeedsLayout];
}

@end
