#import "AGImageView.h"
#import "AGImageCache.h"
#import "AGLayoutManager.h"

@implementation AGImageView

@synthesize shouldShowActivityIndicator;
@synthesize useActivityIndicator;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    // indicator
    indicator = [[AGActivityIndicatorView alloc] initWithImage:AG_LOADING_IMAGE];
    [self addSubview:indicator];
    [indicator release];
    indicator.hidden = YES;
    shouldShowActivityIndicator = NO;
    useActivityIndicator = YES;

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat indicatorPrefferedSize = AG_LOADING_SIZE;
    CGFloat indicatorSize = MIN(indicatorPrefferedSize, MIN(self.bounds.size.width, self.bounds.size.height));

    indicator.frame = CGRectMake(0, 0, indicatorSize, indicatorSize);
    indicator.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
}

- (void)setImage:(UIImage *)image_ {
    [super setImage:image_];

    [self updateActivityIndicator];
}

- (void)setShouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator_ {
    if (shouldShowActivityIndicator == shouldShowActivityIndicator_) return;

    shouldShowActivityIndicator = shouldShowActivityIndicator_;

    [self updateActivityIndicator];
}

- (void)setUseActivityIndicator:(BOOL)useActivityIndicator_ {
    if (useActivityIndicator == useActivityIndicator_) return;

    useActivityIndicator = useActivityIndicator_;

    [self updateActivityIndicator];
}

- (void)updateActivityIndicator {
    if (shouldShowActivityIndicator && useActivityIndicator && !self.image) {
        indicator.hidden = NO;
    } else {
        indicator.hidden = YES;
    }
}

@end
