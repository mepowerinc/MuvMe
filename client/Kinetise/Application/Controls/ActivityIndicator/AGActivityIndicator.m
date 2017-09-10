#import "AGActivityIndicator.h"
#import "AGActivityIndicatorView.h"
#import "AGActivityIndicatorDesc.h"

@interface AGActivityIndicator (){
    AGActivityIndicatorView *indicator;
}
@end

@implementation AGActivityIndicator

- (void)dealloc {
    [source clearDelegatesAndCancel];
    [source release];
    [super dealloc];
}

- (id)initWithDesc:(AGActivityIndicatorDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // indicator
    indicator = (AGActivityIndicatorView *)contentView;

    // asset
    source = [[AGImageAsset alloc] initWithUri:descriptor_.src.value];
    source.delegate = self;

    return self;
}

- (Class)contentClass {
    return [AGActivityIndicatorView class];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    AGActivityIndicatorDesc *desc = (AGActivityIndicatorDesc *)descriptor;
    CGSize contentSize = CGSizeMake(MAX(desc.viewportWidth, 0), MAX(desc.viewportHeight, 0) );

    source.uri = desc.src.value;
    source.prefferedImageSize = MAX(contentSize.width, contentSize.height);
}

- (void)loadAssets {
    [super loadAssets];

    [source execute];
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    [super assetWillLoad:asset_];
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];

    if (asset_ == source) {
        indicator.image = object;
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];
}

@end
