#import "AGBody.h"
#import "AGBodyDesc.h"
#import "AGControl.h"
#import "AGScrollView.h"

@implementation AGBody

- (void)dealloc {
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        [contentView removeObserver:self forKeyPath:@"contentOffset"];
    }
    [super dealloc];
}

- (id)initWithDesc:(AGBodyDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // needs update scroll
    if (descriptor_.hasVerticalScroll) {
        shouldUpdateScrollView = YES;
        UIScrollView *scrollView = (UIScrollView *)contentView;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        scrollView.clipsToBounds = NO;
    }

    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGBodyDesc *desc = (AGBodyDesc *)descriptor;

    // controls
    for (AGControl *control in controls) {
        AGControlDesc *controlDesc = (AGControlDesc *)control.descriptor;

        control.frame = CGRectMake(controlDesc.positionX+controlDesc.marginLeft.value,
                                   controlDesc.positionY+controlDesc.marginTop.value,
                                   MAX(controlDesc.width.value+controlDesc.borderLeft.value+controlDesc.borderRight.value, 0),
                                   MAX(controlDesc.height.value+controlDesc.borderTop.value+controlDesc.borderBottom.value, 0));

        [control setNeedsLayout];
    }

    // scroll
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        // content size
        UIScrollView *scrollView = (UIScrollView *)contentView;
        scrollView.contentSize = CGSizeMake(desc.contentWidth, desc.contentHeight);

        // content offset
        if (shouldUpdateScrollView) {
            shouldUpdateScrollView = NO;
            CGFloat maxVerticalContentOffset = MAX(scrollView.contentSize.height-scrollView.bounds.size.height, 0);
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, MIN(desc.verticalScrollOffset, maxVerticalContentOffset) );
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView *)scrollView change:(NSDictionary *)change context:(void *)context {
    AGBodyDesc *desc = (AGBodyDesc *)descriptor;

    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
            desc.verticalScrollOffset = MAX(scrollView.contentOffset.y, 0);
        }
    }
}

@end
