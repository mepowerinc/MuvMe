#import "AGSignature.h"
#import "AGSignatureDesc.h"
#import "AGSignatureCanvas.h"
#import "AGApplication.h"
#import "AGLocalizationManager.h"
#import "NSObject+Nil.h"
#import "NSString+GUID.h"
#import <RMUniversalAlert/RMUniversalAlert.h>

@implementation AGSignature

#pragma mark - Initialization

- (void)dealloc {
    [clearSource clearDelegatesAndCancel];
    [clearSource release];
    [clearActiveSource clearDelegatesAndCancel];
    [clearActiveSource release];
    [super dealloc];
}

- (id)initWithDesc:(AGSignatureDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // clear button
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.contentMode = UIViewContentModeScaleAspectFit;
    [clearButton addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:clearButton];
    
    // clear source
    clearSource = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.clearSrc.value] uriString] ];
    clearSource.delegate = self;
    
    // clear active source
    clearActiveSource = [[AGImageAsset alloc] initWithUri:[[descriptor_ fullPath:descriptor_.clearActiveSrc.value] uriString] ];
    clearActiveSource.delegate = self;
    
    // canvas
    AGSignatureCanvas *canvas = (AGSignatureCanvas *)self.contentView;
    
    // stroke size
    canvas.strokeWidth = descriptor_.strokeWidth.value;
    
    // stroke color
    canvas.strokeColor = [UIColor colorWithRed:descriptor_.strokeColor.r green:descriptor_.strokeColor.g blue:descriptor_.strokeColor.b alpha:descriptor_.strokeColor.a];
    
    // value
    [self setValue:descriptor_.form.value ];
    
    return self;
}

- (Class)contentClass {
    return [AGSignatureCanvas class];
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGSignatureDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }
    
    // value
    [self setValue:descriptor_.form.value ];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    CGSize contentSize = CGSizeMake(MAX(desc.viewportWidth, 0), MAX(desc.viewportHeight, 0) );
    
    clearSource.uri = [[desc fullPath:desc.clearSrc.value] uriString];
    clearSource.prefferedImageSize = MAX(contentSize.width, contentSize.height);
    
    clearActiveSource.uri = [[desc fullPath:desc.clearActiveSrc.value] uriString];
    clearActiveSource.prefferedImageSize = MAX(contentSize.width, contentSize.height);
}

- (void)loadAssets {
    [super loadAssets];
    
    [clearSource execute];
    [clearActiveSource execute];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    
    // clear button
    clearButton.frame = CGRectMake(contentView.bounds.size.width-desc.clearSize.value-desc.clearMargin.value, contentView.bounds.size.height-desc.clearSize.value-desc.clearMargin.value, desc.clearSize.value, desc.clearSize.value);
}

#pragma mark - Lifecycle

- (void)onClear {
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    
    // responder
    [self becomeFirstResponder];
    
    // value
    [self setValue:nil];
    
    // validate
    if (![desc.form isValid:desc.form.value]) {
        [self validate];
    } else {
        [self invalidate];
    }
}

#pragma mark - Form

- (void)setValue:(UIBezierPath *)value_ {
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    AGSignatureCanvas *canvas = (AGSignatureCanvas *)self.contentView;
    
    // value
    desc.form.value = canvas.path;
    
    // canvas
    if (value_) {
        canvas.path = desc.form.value;
    } else {
        [canvas erase];
    }
}

#pragma mark - Reset

- (void)reset {
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    
    // value
    [self setValue:desc.form.value ];
    
    // invalidate
    [self invalidate];
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    
    // validate
    if (![desc.form isValid:desc.form.value]) {
        [self validate];
    } else {
        [self invalidate];
    }
    
    return [super resignFirstResponder];
}

#pragma mark - Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    AGSignatureCanvas *canvas = (AGSignatureCanvas *)self.contentView;
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) {
        return canvas;
    }
    
    return hitView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    AGSignatureCanvas *canvas = (AGSignatureCanvas *)self.contentView;
    
    // invalidate
    [self invalidate];
    
    // responder
    [self becomeFirstResponder];
    
    // value
    desc.form.value = canvas.path;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    AGSignatureCanvas *canvas = (AGSignatureCanvas *)self.contentView;
    
    // value
    desc.form.value = canvas.path;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    AGSignatureDesc *desc = (AGSignatureDesc *)descriptor;
    AGSignatureCanvas *canvas = (AGSignatureCanvas *)self.contentView;
    
    // value
    desc.form.value = canvas.path;
}

#pragma mark - AGAssetDelegate

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];
    
    if (asset_ == clearSource) {
        [clearButton setImage:object forState:UIControlStateNormal];
    } else if (asset_ == clearActiveSource) {
        [clearButton setImage:object forState:UIControlStateHighlighted];
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];
    
    if (asset_ == clearSource) {
        [clearButton setImage:AG_ERROR_IMAGE forState:UIControlStateNormal];
    } else if (asset_ == clearActiveSource) {
        [clearButton setImage:AG_ERROR_IMAGE forState:UIControlStateHighlighted];
    }
}

@end
