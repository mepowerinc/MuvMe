#import "AGEditableText.h"
#import "AGEditableTextDesc.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"
#import "CGRect+Round.h"
#import "AGFontManager.h"

@implementation AGEditableText

@synthesize textAttributes;
@synthesize invalidAttributes;
@synthesize placeholderAttributes;
@synthesize textInput;

#pragma mark - Initialization

- (void)dealloc {
    self.textAttributes = nil;
    self.invalidAttributes = nil;
    self.placeholderAttributes = nil;
    [iconAsset clearDelegatesAndCancel];
    [iconAsset release];
    [super dealloc];
}

- (id)initWithDesc:(AGEditableTextDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // text input
    textInput = self.textInput;
    
    // keyboard type
    if (descriptor_.keyboardType == keyboardTypeText) {
        textInput.keyboardType = UIKeyboardTypeDefault;
    } else if (descriptor_.keyboardType == keyboardTypeURL) {
        textInput.keyboardType = UIKeyboardTypeURL;
    } else if (descriptor_.keyboardType == keyboardTypeEmail) {
        textInput.keyboardType = UIKeyboardTypeEmailAddress;
    } else if (descriptor_.keyboardType == keyboardTypeNumber) {
        textInput.keyboardType = UIKeyboardTypeNumberPad;
    } else if (descriptor_.keyboardType == keyboardTypePhone) {
        textInput.keyboardType = UIKeyboardTypePhonePad;
    } else if (descriptor_.keyboardType == keyboardTypeDecimal) {
        textInput.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    // text attributes
    UIFont *font = [AGFONTMANAGER fontWithSize:descriptor_.textStyle.fontSize.value bold:descriptor_.textStyle.isBold italic:descriptor_.textStyle.isItalic];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (descriptor_.textStyle.textAlign == alignLeft) {
        paragraphStyle.alignment = NSTextAlignmentLeft;
    } else if (descriptor_.textStyle.textAlign == alignRight) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    } else if (descriptor_.textStyle.textAlign == alignCenter) {
        paragraphStyle.alignment = NSTextAlignmentCenter;
    }
    
    NSMutableDictionary *placeholderTextAttributes = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *defaultTextAttributes = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *invalidTextAttributes = [[NSMutableDictionary alloc] init];
    
    placeholderTextAttributes[NSFontAttributeName] = font;
    defaultTextAttributes[NSFontAttributeName] = font;
    invalidTextAttributes[NSFontAttributeName] = font;
    
    placeholderTextAttributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:descriptor_.textStyle.watermarkColor.r green:descriptor_.textStyle.watermarkColor.g blue:descriptor_.textStyle.watermarkColor.b alpha:descriptor_.textStyle.watermarkColor.a];
    defaultTextAttributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:descriptor_.textStyle.textColor.r green:descriptor_.textStyle.textColor.g blue:descriptor_.textStyle.textColor.b alpha:descriptor_.textStyle.textColor.a];
    invalidTextAttributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:descriptor_.textStyle.textInvalidColor.r green:descriptor_.textStyle.textInvalidColor.g blue:descriptor_.textStyle.textInvalidColor.b alpha:descriptor_.textStyle.textInvalidColor.a];
    
    placeholderTextAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    defaultTextAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    invalidTextAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    if (descriptor_.textStyle.isUnderline) {
        placeholderTextAttributes[NSUnderlineStyleAttributeName] = @(1);
        defaultTextAttributes[NSUnderlineStyleAttributeName] = @(1);
        invalidTextAttributes[NSUnderlineStyleAttributeName] = @(1);
    }
    
    self.textAttributes = defaultTextAttributes;
    self.invalidAttributes = invalidTextAttributes;
    self.placeholderAttributes = placeholderTextAttributes;
    
    [paragraphStyle release];
    [placeholderTextAttributes release];
    [defaultTextAttributes release];
    [invalidTextAttributes release];
    
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
    }
    
    // actions
    [(UIControl *) textInput addTarget:self action:@selector(onEditingChange) forControlEvents:UIControlEventEditingChanged];
    [(UIControl *) textInput addTarget:self action:@selector(onEditingBegin) forControlEvents:UIControlEventEditingDidBegin];
    [(UIControl *) textInput addTarget:self action:@selector(onEditingEnd) forControlEvents:UIControlEventEditingDidEnd];
    
    return self;
}

#pragma mark - Form

- (void)setValue:(id)value {
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGEditableTextDesc *desc = (AGEditableTextDesc *)descriptor;
    
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
    
    // text input
    CGRect inputFrame = CGRectMake(desc.textStyle.textPaddingLeft.value,
                                   desc.textStyle.textPaddingTop.value,
                                   MAX(contentView.bounds.size.width - iconView.bounds.size.width - desc.textStyle.textPaddingLeft.value - desc.textStyle.textPaddingRight.value, 0),
                                   MAX(contentView.bounds.size.height - desc.textStyle.textPaddingTop.value - desc.textStyle.textPaddingBottom.value, 0));
    
    if (desc.iconAlign == alignLeft) {
        inputFrame.origin.x += iconView.bounds.size.width;
    }
    
    textInput.frame = inputFrame;
    
    // round text input frame
    CGRect globalRect = [self convertRect:textInput.frame toView:nil];
    CGRect globalIntegralRect = CGRectRound(globalRect);
    textInput.frame = [self convertRect:globalIntegralRect fromView:nil];
}

#pragma mark - Appearance

- (void)updateAppearance {
    [super updateAppearance];
    
    // icon
    iconView.image = [self getCurrentAppearance:@"icon"];
}

#pragma mark - Reset

- (void)reset {
    [self invalidate];
}

#pragma mark - Editing

- (void)onEditingWillBegin {
    textInput.returnKeyType = UIReturnKeyNext;
    
    // forms
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    AGPresenter *presenter = [AGAPPLICATION getControlPresenter:self];
    [AGAPPLICATION getInputControls:presenter withArray:forms];
    
    if (self == forms.lastObject) {
        textInput.returnKeyType = UIReturnKeyDefault;
    }
    
    [forms release];
}

- (void)onEditingBegin {
    
}

- (void)onEditingEnd {
    [self validate];
}

- (void)onEditingChange {
    AGEditableTextDesc *desc = (AGEditableTextDesc *)descriptor;
    
    // validate
    if ([desc.form isValid:desc.form.value]) {
        [self invalidate];
    }
}

#pragma mark - Input

- (BOOL)onNext {
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    AGPresenter *presenter = [AGAPPLICATION getControlPresenter:self];
    [AGAPPLICATION getInputControls:presenter withArray:forms];
    
    NSInteger formIndex = NSNotFound;
    for (int i = 0; i < forms.count; ++i) {
        AGControl *control = forms[i];
        if (control == self) {
            formIndex = i;
            break;
        }
    }
    
    AGControl *nextForm = nil;
    if (formIndex != NSNotFound) {
        formIndex += 1;
        if (formIndex >= 0 && formIndex < forms.count) {
            nextForm = forms[formIndex];
            [nextForm becomeFirstResponder];
        }
    }
    
    if (nextForm) {
        [forms release];
        return YES;
    }
    
    [forms release];
    
    return NO;
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    if (!textInput.isFirstResponder) {
        [textInput becomeFirstResponder];
    }
    return YES;
}

#pragma mark - Touches

- (void)onTap:(CGPoint)point {
    [self becomeFirstResponder];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    AGEditableTextDesc *desc = (AGEditableTextDesc *)descriptor;
    CGSize iconSize = CGSizeMake(MAX(desc.iconWidth.value, 0), MAX(desc.iconHeight.value, 0) );
    
    // icon asset
    iconAsset.uri = [[desc fullPath:desc.iconSrc.value] uriString];
    iconAsset.prefferedImageSize = MAX(iconSize.width, iconSize.height);
}

- (void)loadAssets {
    [super loadAssets];
    
    [iconAsset execute];
}

#pragma mark - AGAssetDelegate

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    [super asset:asset_ didLoad:object];
    
    if (asset_ == iconAsset) {
        [self setAppearance:@"icon" withObject:object forState:UIControlStateNormal];
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    [super asset:asset_ didFail:error];
    
    if (asset_ == iconAsset) {
        [self setAppearance:@"icon" withObject:AG_ERROR_IMAGE forState:UIControlStateNormal];
    }
}

@end
