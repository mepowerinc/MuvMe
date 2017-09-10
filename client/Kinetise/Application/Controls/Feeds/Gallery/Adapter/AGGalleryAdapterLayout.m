#import "AGGalleryAdapterLayout.h"
#import "AGGalleryDesc.h"

@implementation AGGalleryAdapterLayout

- (id)initWithDesc:(AGGalleryDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    return self;
}

#pragma mark - Lifecycle

- (NSArray *)indexPathsOfItemsInRect:(CGRect)rect {
    NSMutableArray *indexPaths = [NSMutableArray array];

    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < itemCount; ++i) {
        CGRect itemRect = CGRectMake( (2*AG_GALLERY_DETAIL_PADDING+descriptor.blockWidth)*i, 0, descriptor.blockWidth+2*AG_GALLERY_DETAIL_PADDING, descriptor.blockHeight);
        if (CGRectIntersectsRect(rect, itemRect) ) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0] ];
        }
    }

    return indexPaths;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];

    NSArray *visibleIndexPaths = [self indexPathsOfItemsInRect:rect];

    for (NSIndexPath *indexPath in visibleIndexPaths) {
        UICollectionViewLayoutAttributes *attributes =
            [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributes addObject:attributes];
    }

    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake( (2*AG_GALLERY_DETAIL_PADDING+descriptor.blockWidth)*indexPath.item, 0, descriptor.blockWidth+2*AG_GALLERY_DETAIL_PADDING, descriptor.blockHeight);

    return attributes;
}

- (CGSize)collectionViewContentSize {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];

    return CGSizeMake( (2*AG_GALLERY_DETAIL_PADDING+descriptor.blockWidth)*itemCount, descriptor.blockHeight);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end
