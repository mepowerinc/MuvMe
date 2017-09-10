#import "AGGallery.h"
#import "AGGalleryDesc.h"
#import "NSIndexPath+Array.h"
#import "UIView+Debug.h"

@implementation AGGallery

- (id)initWithDesc:(AGGalleryDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // adapter
    adapter = (AGGalleryAdapter *)contentView;

    return self;
}

#pragma mark - Lifecycle

- (Class)contentClass {
    return [AGGalleryAdapter class];
}

- (UIView *)newContent {
    return [[[self contentClass] alloc] initWithDesc:descriptor];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    [adapter setupAssets];
}

- (void)loadAssets {
    [super loadAssets];

    [adapter loadAssets];
}

#pragma mark - Reload

- (void)reloadData {
    [adapter reloadData];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGGalleryDesc *desc = (AGGalleryDesc *)descriptor;

    // content
    contentView.frame = CGRectMake(desc.paddingLeft.value+desc.borderLeft.value-AG_GALLERY_DETAIL_PADDING,
                                   desc.paddingTop.value+desc.borderTop.value,
                                   MAX(desc.viewportWidth, 0)+2*AG_GALLERY_DETAIL_PADDING,
                                   MAX(desc.viewportHeight, 0));
    [contentView setNeedsLayout];

    // page index
    NSInteger pageIndex = desc.feed.itemIndex;
    adapter.contentOffset = CGPointMake(pageIndex*contentView.bounds.size.width, 0);;
}

@end
