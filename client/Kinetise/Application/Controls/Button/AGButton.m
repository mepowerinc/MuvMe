#import "AGButton.h"
#import "AGButtonDesc.h"

@implementation AGButton

#pragma mark - Initialization

- (void)dealloc {
    [activeSource clearDelegatesAndCancel];
    [activeSource release];
    [invalidSource clearDelegatesAndCancel];
    [invalidSource release];
    [super dealloc];
}

- (id)initWithDesc:(AGButtonDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // active border color
    UIColor *activeBorderColor = [UIColor colorWithRed:descriptor_.activeBorderColor.r green:descriptor_.activeBorderColor.g blue:descriptor_.activeBorderColor.b alpha:descriptor_.activeBorderColor.a];
    [self setAppearance:@"border_color" withObject:activeBorderColor forState:UIControlStateHighlighted];

    // active source
    if (descriptor_.activeSrc) {
        activeSource = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.activeSrc.value] uriString] ];
        activeSource.delegate = self;
    }

    // invalid source
    if (descriptor_.invalidSrc) {
        invalidSource = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.invalidSrc.value] uriString] ];
        invalidSource.delegate = self;
    }

    return self;
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];

    AGButtonDesc *desc = (AGButtonDesc *)descriptor;

    // text
    if (self.isInvalid) {
        desc.string.color = desc.textStyle.textInvalidColor;
        label.string = desc.string;
    } else if (self.isHighlighted) {
        desc.string.color = desc.textStyle.textActiveColor;
        label.string = desc.string;
    } else if (self.isSelected) {
        desc.string.color = desc.textStyle.textActiveColor;
        label.string = desc.string;
    } else {
        desc.string.color = desc.textStyle.textColor;
    }
    label.string = desc.string;
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Touches

- (void)onTouchBegan:(CGPoint)point {
    [super onTouchBegan:point];

    self.highlighted = YES;
}

- (void)onTouchMoved:(CGPoint)point {
    [super onTouchMoved:point];

    if (![self pointInside:point withEvent:nil]) {
        self.highlighted = NO;
    } else {
        self.highlighted = YES;
    }

    [super onTouchMoved:point];
}

- (void)onTouchEnded:(CGPoint)point {
    [super onTouchEnded:point];

    self.highlighted = NO;
}

- (void)onTouchCancelled:(CGPoint)point {
    [super onTouchCancelled:point];

    self.highlighted = NO;
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    AGButtonDesc *desc = (AGButtonDesc *)descriptor;
    CGSize contentSize = CGSizeMake(MAX(desc.viewportWidth, 0), MAX(desc.viewportHeight, 0) );

    // active source
    activeSource.uri = [[desc fullPath:desc.activeSrc.value] uriString];
    activeSource.httpQueryParams = [desc.activeHttpQueryParams execute:self];
    activeSource.httpHeaderParams = [desc.activeHttpHeaderParams execute:self];
    activeSource.prefferedImageSize = MAX(contentSize.width, contentSize.height);

    // invalid source
    invalidSource.uri = [[desc fullPath:desc.invalidSrc.value] uriString];
    invalidSource.httpQueryParams = [desc.invalidHttpQueryParams execute:self];
    invalidSource.httpHeaderParams = [desc.invalidHttpHeaderParams execute:self];
    invalidSource.prefferedImageSize = MAX(contentSize.width, contentSize.height);
}

- (void)loadAssets {
    [super loadAssets];

    [activeSource execute];
    [invalidSource execute];
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    [super assetWillLoad:asset_];

    if (asset_ == activeSource && asset_.assetType == assetHttp) {
        [self setAppearance:@"image" withObject:nil forState:UIControlStateHighlighted];
    } else if (asset_ == invalidSource && asset_.assetType == assetHttp) {
        [self setAppearance:@"image" withObject:nil forState:UIControlStateInvalid];
    }
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];

    if (asset_ == activeSource) {
        [self setAppearance:@"image" withObject:object forState:UIControlStateHighlighted];
    } else if (asset_ == invalidSource) {
        [self setAppearance:@"image" withObject:object forState:UIControlStateInvalid];
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];

    if (asset_ == activeSource) {
        [self setAppearance:@"image" withObject:AG_ERROR_IMAGE forState:UIControlStateHighlighted];
    } else if (asset_ == invalidSource) {
        [self setAppearance:@"image" withObject:AG_ERROR_IMAGE forState:UIControlStateInvalid];
    }
}

@end
