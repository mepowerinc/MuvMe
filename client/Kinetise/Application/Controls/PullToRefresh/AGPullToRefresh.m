#import "AGPullToRefresh.h"
#import "AGLayoutManager.h"
#import "AGLocalizationManager.h"

@interface AGPullToRefresh ()<UIScrollViewDelegate>{
    UILabel *label;
}

@end

@implementation AGPullToRefresh

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // label
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:AG_FONT_NAME size:AG_PULL_TO_REFRESH_FONT_SIZE];
    label.text = [AGLOCALIZATION localizedString:@"PULL_TO_REFRESH"];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowRadius = 1.0f;
    label.layer.shadowOpacity = 1.0f;
    label.layer.shadowOffset = CGSizeMake(0, 0);
    label.layer.shouldRasterize = YES;
    label.layer.rasterizationScale = [UIScreen mainScreen].scale;
    label.hidden = YES;
    [self addSubview:label];
    [label release];

    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];

    // observer
    if (newSuperview) {
        if ([newSuperview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)newSuperview;
            scrollView.delegate = self;
        }
    } else {
        if ([self.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)self.superview;
            scrollView.delegate = nil;
        }
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    label.frame = self.bounds;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat refreshInset = self.bounds.size.height;
    CGFloat minOffsetToTriggerRefresh = refreshInset*2;

    // percentage
    CGFloat percentage = (scrollView.contentOffset.y+1.5f*refreshInset)/refreshInset;
    percentage = MIN(percentage, 1);
    percentage = MAX(percentage, 0);
    label.alpha = 1.0f-percentage;
    label.hidden = NO;

    // label
    if (scrollView.contentOffset.y < -minOffsetToTriggerRefresh) {
        label.text = [AGLOCALIZATION localizedString:@"RELEASE_TO_REFRESH"];
    } else {
        label.text = [AGLOCALIZATION localizedString:@"PULL_TO_REFRESH"];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    CGFloat refreshInset = self.bounds.size.height;
    CGFloat minOffsetToTriggerRefresh = refreshInset*2;

    if (scrollView.contentOffset.y < -minOffsetToTriggerRefresh) {
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        scrollView.scrollEnabled = NO;

        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -self.bounds.size.height);
        } completion:^(BOOL finished) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
            scrollView.scrollEnabled = YES;
        }];
    }
}

@end
