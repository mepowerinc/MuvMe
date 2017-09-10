#import "AGPinchImage.h"
#import "AGPinchImageDesc.h"
#import "UIView+Hierarchy.h"
#import "AGApplication.h"

@implementation AGPinchImage

- (id)initWithDesc:(AGPinchImageDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // scroll view
    scrollView = (UIScrollView *)contentView;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 3;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    
    // label
    [label removeFromSuperview];
    label = nil;
    
    return self;
}

- (Class)contentClass {
    return [UIScrollView class];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGControlDesc *desc = (AGControlDesc *)descriptor;
    
    // image view
    imageView.frame = CGRectMake(0,
                                 0,
                                 MAX(desc.viewportWidth * scrollView.zoomScale, 0),
                                 MAX(desc.viewportHeight * scrollView.zoomScale, 0));
    
    // scroll view
    scrollView.contentSize = imageView.frame.size;
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGControlDesc *desc = (AGControlDesc *)descriptor;
    CGSize contentSize = CGSizeMake(MAX(desc.viewportWidth, 0), MAX(desc.viewportHeight, 0) );
    
    source.prefferedImageSize = scrollView.maximumZoomScale*MAX(contentSize.width, contentSize.height);
    
    if ([source.uri hasPrefix:@"assets://"] || [source.uri hasPrefix:@"local://"]) {
        source.cachePolicy = cachePolicyDoNotCache;
    } else {
        source.cachePolicy = cachePolicyDefault;
    }
    
    if ([backgroundSource.uri hasPrefix:@"assets://"] || [backgroundSource.uri hasPrefix:@"local://"]) {
        backgroundSource.cachePolicy = cachePolicyDoNotCache;
    } else {
        backgroundSource.cachePolicy = cachePolicyDefault;
    }
}

- (void)loadAssets {
    [super loadAssets];
    
    scrollView.zoomScale = 1;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

@end
