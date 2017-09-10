#import "AGText.h"
#import "AGTextDesc.h"
#import "CGRect+Round.h"

@implementation AGText

@synthesize label;

- (id)initWithDesc:(AGTextDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // label
    label = [[AGLabel alloc] initWithFrame:CGRectZero];
    label.textValign = descriptor_.textStyle.textValign;
    label.textAlign = descriptor_.textStyle.textAlign;
    label.backgroundColor = [UIColor clearColor];
    [contentView addSubview:label];
    [label release];
    
    return self;
}

#pragma mark - Assets

- (void)loadAssets {
    [super loadAssets];
    
    AGTextDesc *desc = (AGTextDesc *)descriptor;
    
    // label
    label.string = desc.string;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    AGTextDesc *desc = (AGTextDesc *)descriptor;
    
    // label
    label.string = desc.string;
    
    // label
    label.frame = CGRectMake(desc.textStyle.textPaddingLeft.value,
                             desc.textStyle.textPaddingTop.value,
                             MAX(contentView.bounds.size.width - desc.textStyle.textPaddingLeft.value - desc.textStyle.textPaddingRight.value, 0),
                             MAX(contentView.bounds.size.height - desc.textStyle.textPaddingTop.value - desc.textStyle.textPaddingBottom.value, 0));
    [label setNeedsLayout];
    [label setNeedsDisplay];
    
    // round label frame
    CGRect globalRect = [self convertRect:label.frame toView:nil];
    CGRect globalIntegralRect = CGRectRound(globalRect);
    label.frame = [self convertRect:globalIntegralRect fromView:nil];
}

@end
