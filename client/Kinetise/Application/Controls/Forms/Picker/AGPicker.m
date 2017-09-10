#import "AGPicker.h"
#import "AGPickerDesc.h"
#import "AGActionManager.h"
#import "CGRect+Round.h"

@implementation AGPicker

#pragma mark - Initialization

- (id)initWithDesc:(AGPickerDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // icon
    if (descriptor_.iconSrc) {
        // view
        iconView = [[AGImageView alloc] initWithFrame:CGRectZero];
        iconView.clipsToBounds = YES;
        iconView.userInteractionEnabled = NO;
        [contentView addSubview:iconView];
        [iconView release];
        
        // size mode
        if (descriptor_.iconSizeMode == sizeModeStretch) {
            iconView.contentMode = UIViewContentModeScaleToFill;
        } else if (descriptor_.iconSizeMode == sizeModeShortedge) {
            iconView.contentMode = UIViewContentModeScaleAspectFill;
        } else if (descriptor_.iconSizeMode == sizeModeLongedge) {
            iconView.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        // asset
        iconAsset = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.iconSrc.value] uriString] ];
        iconAsset.delegate = self;
        
        // active asset
        iconActiveAsset = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.iconActiveSrc.value] uriString] ];
        iconActiveAsset.delegate = self;
    }
    
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGPickerDesc *desc = (AGPickerDesc *)descriptor;
    
    // icon
    CGRect iconFrame = CGRectMake(0, 0, desc.iconWidth.value, desc.iconHeight.value);
    
    if (desc.iconAlign == alignLeft) {
        iconFrame.origin.x = 0;
    } else if (desc.iconAlign == alignRight) {
        iconFrame.origin.x = contentView.frame.size.width - iconFrame.size.width;
    }
    
    if (desc.iconValign == valignTop) {
        iconFrame.origin.y = 0;
    } else if (desc.iconValign == valignCenter) {
        iconFrame.origin.y = (contentView.bounds.size.height - iconFrame.size.height) * 0.5f;
    } else if (desc.iconValign == valignBottom) {
        iconFrame.origin.y = contentView.bounds.size.height - iconFrame.size.height;
    }
    
    iconView.frame = iconFrame;
    
    // label
    CGRect labelFrame = CGRectMake(desc.textStyle.textPaddingLeft.value,
                                   desc.textStyle.textPaddingTop.value,
                                   MAX(contentView.bounds.size.width - iconView.bounds.size.width - desc.textStyle.textPaddingLeft.value - desc.textStyle.textPaddingRight.value, 0),
                                   MAX(contentView.bounds.size.height - desc.textStyle.textPaddingTop.value - desc.textStyle.textPaddingBottom.value, 0));
    
    if (desc.iconAlign == alignLeft) {
        labelFrame.origin.x += iconView.bounds.size.width;
    }
    
    label.frame = labelFrame;
    [label setNeedsLayout];
    
    // round text input frame
    CGRect globalRect = [self convertRect:label.frame toView:nil];
    CGRect globalIntegralRect = CGRectRound(globalRect);
    label.frame = [self convertRect:globalIntegralRect fromView:nil];
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];
    
    // icon
    iconView.image = [self getCurrentAppearance:@"icon"];
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    AGPickerDesc *desc = (AGPickerDesc *)descriptor;
    
    // on end editing
    dispatch_async(dispatch_get_main_queue(), ^{
        if (desc.onEndEditing) {
            [AGACTIONMANAGER executeAction:desc.onEndEditing withSender:desc];
        }
    });
    
    return [super resignFirstResponder];
}

#pragma mark - Form

- (void)setValue:(NSString *)value_ {
    
}

#pragma mark - Reset

- (void)reset {
    AGPickerDesc *desc = (AGPickerDesc *)descriptor;
    
    // value
    [self setValue:desc.form.value ];
    
    // invalidate
    [self invalidate];
}

#pragma mark - Touches

- (void)onTap:(CGPoint)point {
    [self becomeFirstResponder];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGPickerDesc *desc = (AGPickerDesc *)descriptor;
    CGSize iconSize = CGSizeMake(MAX(desc.iconWidth.value, 0), MAX(desc.iconHeight.value, 0) );
    
    // icon asset
    iconAsset.uri = [[desc fullPath:desc.iconSrc.value] uriString];
    iconAsset.prefferedImageSize = MAX(iconSize.width, iconSize.height);
    
    // active icon asset
    iconActiveAsset.uri = [[desc fullPath:desc.iconActiveSrc.value] uriString];
    iconActiveAsset.prefferedImageSize = MAX(iconSize.width, iconSize.height);
}

- (void)loadAssets {
    [super loadAssets];
    
    [iconAsset execute];
    [iconActiveAsset execute];
}

#pragma mark - AGAssetDelegate

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];
    
    if (asset_ == iconAsset) {
        [self setAppearance:@"icon" withObject:object forState:UIControlStateNormal];
    } else if (asset_ == iconActiveAsset) {
        [self setAppearance:@"icon" withObject:object forState:UIControlStateHighlighted];
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];
    
    if (asset_ == iconAsset) {
        [self setAppearance:@"icon" withObject:AG_ERROR_IMAGE forState:UIControlStateNormal];
    } else if (asset_ == iconActiveAsset) {
        [self setAppearance:@"icon" withObject:AG_ERROR_IMAGE forState:UIControlStateHighlighted];
    }
}

@end
