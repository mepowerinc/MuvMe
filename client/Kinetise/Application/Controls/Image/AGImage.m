#import "AGImage.h"
#import "AGImageDesc.h"
#import "UIView+Hierarchy.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"
#import "AGGalleryDesc.h"

@implementation AGImage

#pragma mark - Initialization

- (void)dealloc {
    [source clearDelegatesAndCancel];
    [source release];
    [super dealloc];
}

- (id)initWithDesc:(AGImageDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // image view
    imageView = [[AGImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    [contentView addSubview:imageView];
    [imageView release];
    [label bringToFront];
    
    // show loading
    imageView.useActivityIndicator = descriptor_.showLoading;
    
    // size mode
    if (descriptor_.sizeMode == sizeModeStretch) {
        imageView.contentMode = UIViewContentModeScaleToFill;
    } else if (descriptor_.sizeMode == sizeModeShortedge) {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if (descriptor_.sizeMode == sizeModeLongedge) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    // asset
    if (descriptor_.src) {
        source = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.src.value] uriString] ];
        source.delegate = self;
    }
    
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGImageDesc *desc = (AGImageDesc *)descriptor;
    
    // image
    if (label && desc.string.string.length > 0) {
        CGFloat textHeight = MAX(desc.string.size.height + desc.textStyle.textPaddingTop.value + desc.textStyle.textPaddingBottom.value, 0);
        
        if (desc.textStyle.textValign == valignAbove) {
            imageView.frame = CGRectMake(0, textHeight, contentView.bounds.size.width, MAX(contentView.bounds.size.height-textHeight, 0) );
        } else if (desc.textStyle.textValign == valignBelow) {
            imageView.frame = CGRectMake(0, 0, contentView.bounds.size.width, MAX(contentView.bounds.size.height-textHeight, 0) );
        } else {
            imageView.frame = contentView.bounds;
        }
    } else {
        imageView.frame = contentView.bounds;
    }
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];
    
    // image
    imageView.image = [self getCurrentAppearance:@"image"];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGImageDesc *desc = (AGImageDesc *)descriptor;
    CGSize contentSize = CGSizeMake(MAX(desc.viewportWidth, 0), MAX(desc.viewportHeight, 0) );
    
    source.uri = [[desc fullPath:desc.src.value] uriString];
    source.httpQueryParams = [desc.httpQueryParams execute:self];
    source.httpHeaderParams = [desc.httpHeaderParams execute:self];
    source.prefferedImageSize = MAX(contentSize.width, contentSize.height);
    
    if ([AGAPPLICATION isControl:desc liesOnControlOfType:[AGGalleryDesc class]] && ([source.uri hasPrefix:@"assets://"] || [source.uri hasPrefix:@"local://"]) ) {
        source.cachePolicy = cachePolicyDoNotCache;
    } else {
        source.cachePolicy = cachePolicyDefault;
    }
}

- (void)loadAssets {
    [super loadAssets];
    
    [source execute];
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    [super assetWillLoad:asset_];
    
    if (asset_ == source && asset_.assetType == assetHttp) {
        imageView.shouldShowActivityIndicator = !asset_.isCachedData;
        [self setAppearance:@"image" withObject:nil forState:UIControlStateNormal];
    }
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];
    
    if (asset_ == source) {
        if (asset_.assetType == assetHttp && !asset_.isCachedData) {
            imageView.alpha = 0;
            [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                imageView.alpha = 1.0f;
            } completion:nil];
        }
        
        [self setAppearance:@"image" withObject:object forState:UIControlStateNormal];
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];
    
    if (asset_ == source) {
        [self setAppearance:@"image" withObject:AG_ERROR_IMAGE forState:UIControlStateNormal];
    }
}

@end
