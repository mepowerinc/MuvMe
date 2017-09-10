#import "AGCompoundButton.h"
#import "AGCompoundButtonDesc.h"
#import "CGRect+Round.h"

@implementation AGCompoundButton

#pragma mark - Initialization

- (id)initWithDesc:(AGCompoundButtonDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    // value
    self.selected = [descriptor_.form.value boolValue];
    
    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGCompoundButtonDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }
    
    // value
    self.selected = [descriptor_.form.value boolValue];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGCompoundButtonDesc *desc = (AGCompoundButtonDesc *)descriptor;
    
    // label
    label.frame = CGRectMake(desc.textStyle.textPaddingLeft.value + desc.checkWidth.value + desc.innerSpace.value,
                             desc.textStyle.textPaddingTop.value,
                             MAX(contentView.bounds.size.width - desc.textStyle.textPaddingLeft.value - desc.textStyle.textPaddingRight.value - desc.checkWidth.value - desc.innerSpace.value, 0),
                             MAX(contentView.bounds.size.height - desc.textStyle.textPaddingTop.value - desc.textStyle.textPaddingBottom.value, 0));
    [label setNeedsLayout];
    
    // round label frame
    CGRect globalRect = [self convertRect:label.frame toView:nil];
    CGRect globalIntegralRect = CGRectRound(globalRect);
    label.frame = [self convertRect:globalIntegralRect fromView:nil];
    
    // image view
    if (desc.checkValign == valignTop) {
        imageView.frame = CGRectMake(0, 0, desc.checkWidth.value, desc.checkHeight.value);
    } else if (desc.checkValign == valignCenter) {
        imageView.frame = CGRectMake(0, (contentView.bounds.size.height-desc.checkHeight.value)*0.5, desc.checkWidth.value, desc.checkHeight.value);
    } else if (desc.checkValign == valignBottom) {
        imageView.frame = CGRectMake(0, contentView.bounds.size.height-desc.checkHeight.value, desc.checkWidth.value, desc.checkHeight.value);
    }
}

#pragma mark - Form

- (void)setValue:(NSNumber *)value_ {
    self.selected = [value_ boolValue];
}

- (void)setSelected:(BOOL)selected_ {
    if (self.isSelected == selected_) return;
    
    AGCompoundButtonDesc *desc = (AGCompoundButtonDesc *)descriptor;
    
    // form
    desc.form.value = @(selected_);
    
    // validate
    if (![desc.form isValid:desc.form.value]) {
        [self validate];
    } else {
        [self invalidate];
    }
    
    [super setSelected:selected_];
}

#pragma mark - Reset

- (void)reset {
    AGCompoundButtonDesc *desc = (AGCompoundButtonDesc *)descriptor;
    
    // value
    self.selected = [desc.form.value boolValue];
    
    // invalidate
    [self invalidate];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGCompoundButtonDesc *desc = (AGCompoundButtonDesc *)descriptor;
    CGSize checkSize = CGSizeMake(MAX(desc.checkWidth.value, 0), MAX(desc.checkHeight.value, 0) );
    
    // source
    source.prefferedImageSize = MAX(checkSize.width, checkSize.height);
    
    // active source
    activeSource.prefferedImageSize = MAX(checkSize.width, checkSize.height);
    
    // invalid source
    invalidSource.prefferedImageSize = MAX(checkSize.width, checkSize.height);
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    [super assetWillLoad:asset_];
    
    if (asset_ == activeSource && asset_.assetType == assetHttp) {
        [self setAppearance:@"image" withObject:nil forState:UIControlStateSelected];
    }
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];
    
    if (asset_ == activeSource) {
        [self setAppearance:@"image" withObject:object forState:UIControlStateSelected];
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];
    
    if (asset_ == activeSource) {
        [self setAppearance:@"image" withObject:AG_ERROR_IMAGE forState:UIControlStateSelected];
    }
}

@end
