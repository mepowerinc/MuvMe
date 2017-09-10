#import "AGDataFeedVertical.h"
#import "AGDataFeedVerticalDesc.h"
#import "CGRect+Round.h"

@implementation AGDataFeedVertical

#pragma mark - Reload

- (void)reloadData {
    [super reloadData];

    AGDataFeedVerticalDesc *desc = (AGDataFeedVerticalDesc *)descriptor;

    // autoscroll
    if (desc.invertChildren && desc.children.count > 0) {
        AGControlDesc *itemDesc = desc.children[0];

        if (adapter.contentOffset.y >= adapter.contentSize.height-adapter.bounds.size.height-itemDesc.blockHeight*2) {
            shouldUpdateScrollView = NO;
            [self setNeedsLayout];
            [self layoutIfNeeded];

            CGFloat offset = MAX(adapter.contentSize.height - adapter.frame.size.height - adapter.contentOffset.y, 0);
            [adapter setContentOffset:CGPointMake(adapter.contentOffset.x, adapter.contentOffset.y+offset) animated:YES];
        }
    }
}

@end
