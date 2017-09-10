#import "AGGalleryAdapter.h"
#import "AGGalleryAdapterLayout.h"
#import "AGGalleryAdapterCell.h"
#import "AGGalleryDesc.h"

@interface AGGalleryAdapter (){
    BOOL shouldSetPageIndex;
    NSInteger pageIndex;
}
@end

@implementation AGGalleryAdapter

- (id)initWithDesc:(AGGalleryDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    self.pagingEnabled = YES;

    return self;
}

- (Class)cellClass {
    return [AGGalleryAdapterCell class];
}

- (Class)layoutClass {
    return [AGGalleryAdapterLayout class];
}

#pragma mark - Reload

- (void)reloadData {
    // page index
    pageIndex = descriptor.feed.itemIndex;

    [super reloadData];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    // page index
    pageIndex = descriptor.feed.itemIndex;

    [super reloadItemsAtIndexPaths:indexPaths];
}

- (void)reloadSections:(NSIndexSet *)sections {
    // page index
    pageIndex = descriptor.feed.itemIndex;

    [super reloadSections:sections];
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    shouldSetPageIndex = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    shouldSetPageIndex = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (shouldSetPageIndex) {
        pageIndex = self.contentOffset.x / self.frame.size.width;
        descriptor.feed.itemIndex = pageIndex;
    }
}

@end
