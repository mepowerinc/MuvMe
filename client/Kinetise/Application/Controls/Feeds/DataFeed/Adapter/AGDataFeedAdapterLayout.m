#import "AGDataFeedAdapterLayout.h"
#import "AGDataFeedDesc.h"
#import "AGDataFeedAdapterBorder.h"
#import "AGDataFeedAdapterBorderLayoutAttributes.h"

@implementation AGDataFeedAdapterLayout

- (id)initWithDesc:(AGDataFeedDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // inter lines
    if (descriptor_.innerBorder.valueInUnits) {
        [self registerClass:[AGDataFeedAdapterBorder class] forDecorationViewOfKind:@"innerBorder"];
    }

    return self;
}

#pragma mark - Lifecycle

- (NSArray *)indexPathsOfItemsInRect:(CGRect)rect {
    NSMutableArray *indexPaths = [NSMutableArray array];

    for (int i = 0; i < descriptor.feedControls.count; ++i) {
        AGControlDesc *controlDesc = descriptor.feedControls[i];
        CGRect itemRect = [self controlRect:controlDesc];
        if (CGRectIntersectsRect(rect, itemRect) ) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0] ];
        }
    }

    return indexPaths;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    AGDataFeedDesc *desc = (AGDataFeedDesc *)descriptor;

    NSMutableArray *layoutAttributes = [NSMutableArray array];

    NSArray *visibleIndexPaths = [self indexPathsOfItemsInRect:rect];

    for (NSIndexPath *indexPath in visibleIndexPaths) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributes addObject:attributes];
        if (desc.innerBorder.valueInUnits && indexPath != visibleIndexPaths.lastObject) {
            UICollectionViewLayoutAttributes *decorationAttributes = [self layoutAttributesForDecorationViewOfKind:@"innerBorder" atIndexPath:indexPath];
            [layoutAttributes addObject:decorationAttributes];
        }
    }

    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    AGControlDesc *controlDesc = descriptor.feedControls[indexPath.item];

    attributes.frame = [self controlRect:controlDesc];

    return attributes;
}

- (CGRect)controlRect:(AGControlDesc *)controlDesc {
    return CGRectMake(controlDesc.positionX+controlDesc.marginLeft.value,
                      controlDesc.positionY+controlDesc.marginTop.value,
                      MAX(controlDesc.width.value+controlDesc.borderLeft.value+controlDesc.borderRight.value, 0),
                      MAX(controlDesc.height.value+controlDesc.borderTop.value+controlDesc.borderBottom.value, 0));
}

- (CGSize)collectionViewContentSize {
    AGDataFeedDesc *desc = (AGDataFeedDesc *)descriptor;

    return CGSizeMake(desc.contentWidth, desc.contentHeight);
}

- (AGDataFeedAdapterBorderLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    AGDataFeedDesc *desc = (AGDataFeedDesc *)descriptor;

    AGDataFeedAdapterBorderLayoutAttributes *attributes = [AGDataFeedAdapterBorderLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    AGControlDesc *controlDesc = descriptor.feedControls[indexPath.item];

    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat invScale = 1.0f/scale;
    CGFloat innerBorderSize = roundf(desc.innerBorder.value * scale) * invScale;

    switch (desc.containerLayout) {
    case layoutVertical:
        attributes.frame = CGRectMake(0, MAX(controlDesc.positionY+controlDesc.blockHeight, 0), desc.contentWidth, innerBorderSize);
        break;
    case layoutHorizontal:
        attributes.frame = CGRectMake(MAX(controlDesc.positionX+controlDesc.blockWidth, 0), 0, innerBorderSize, desc.contentHeight);
        break;
    default:
        break;
    }

    attributes.color = [UIColor colorWithRed:desc.childrenSeparatorColor.r green:desc.childrenSeparatorColor.g blue:desc.childrenSeparatorColor.b alpha:desc.childrenSeparatorColor.a];
    attributes.zIndex = 1;

    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)bounds {
    return YES;
}

@end
