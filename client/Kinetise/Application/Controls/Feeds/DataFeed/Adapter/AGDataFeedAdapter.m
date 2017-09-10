#import "AGDataFeedAdapter.h"
#import "AGDataFeedAdapterCell.h"
#import "AGDataFeedAdapterLayout.h"
#import "AGDataFeedDesc.h"
#import "AGDataFeed.h"

@interface AGDataFeedAdapter (){
    CGFloat pageSize;
    NSInteger currentPage;
    BOOL paginationEnabled;
}
@end

@implementation AGDataFeedAdapter

@synthesize paginationEnabled;

- (id)initWithDesc:(AGDataFeedDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    return self;
}

- (Class)cellClass {
    return [AGDataFeedAdapterCell class];
}

- (Class)layoutClass {
    return [AGDataFeedAdapterLayout class];
}

#pragma mark - Paging

- (void)setPaginationEnabled:(BOOL)paginationEnabled_ {
    paginationEnabled = paginationEnabled_;

    if (paginationEnabled) {
        self.decelerationRate = UIScrollViewDecelerationRateFast;
    } else {
        self.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGDataFeedDesc *desc = (AGDataFeedDesc *)descriptor;

    if (paginationEnabled) {
        pageSize = 0;

        if (desc.feedControls.count) {
            AGControlDesc *controlDesc = desc.feedControls[0];

            if (desc.containerLayout == layoutHorizontal) {
                pageSize = controlDesc.positionX+controlDesc.blockWidth;
            } else if (desc.containerLayout == layoutVertical) {
                pageSize = controlDesc.positionY+controlDesc.blockHeight;
            }
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    AGDataFeedDesc *desc = (AGDataFeedDesc *)descriptor;

    if (paginationEnabled) {
        CGFloat contentOffset = 0;
        if (desc.containerLayout == layoutHorizontal) {
            contentOffset = self.contentOffset.x;
        } else if (desc.containerLayout == layoutVertical) {
            contentOffset = self.contentOffset.y;
        }

        currentPage = floor((contentOffset - pageSize / 2) / pageSize) + 1;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView_ withVelocity:(CGPoint)velocity_ targetContentOffset:(inout CGPoint *)targetContentOffset {
    AGDataFeedDesc *desc = (AGDataFeedDesc *)descriptor;

    if (paginationEnabled) {
        NSInteger newPage;

        CGFloat offset = 0;
        CGFloat velocity = 0;
        CGFloat contentSize = 0;
        if (desc.containerLayout == layoutHorizontal) {
            offset = targetContentOffset->x;
            velocity = velocity_.x;
            contentSize = self.contentSize.width;
        } else if (desc.containerLayout == layoutVertical) {
            offset = targetContentOffset->y;
            velocity = velocity_.y;
            contentSize = self.contentSize.height;
        }

        // slow dragging not lifting finger
        if (velocity == 0) {
            newPage = floor((offset - pageSize / 2) / pageSize) + 1;
        } else {
            newPage = velocity > 0 ? currentPage + 1 : currentPage - 1;

            if (newPage < 0)
                newPage = 0;
            if (newPage > contentSize / pageSize)
                newPage = ceil(contentSize / pageSize) - 1;
        }

        if (desc.containerLayout == layoutHorizontal) {
            *targetContentOffset = CGPointMake(newPage * pageSize, targetContentOffset->y);
        } else if (desc.containerLayout == layoutVertical) {
            *targetContentOffset = CGPointMake(targetContentOffset->x, newPage * pageSize);
        }
    }
}

@end
