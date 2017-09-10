#import "AGAdapterCell.h"

@implementation AGAdapterCell

@synthesize control;

#pragma mark - Initialization

- (void)dealloc {
    self.control = nil;
    [super dealloc];
}

#pragma mark - Lifecycle

- (void)setControl:(AGControl *)control_ {
    [control removeFromSuperview];

    control = control_;
    [self.contentView addSubview:control_];
}

#pragma mar - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGControlDesc *desc = (AGControlDesc *)control.descriptor;

    control.frame = CGRectMake(0,
                               0,
                               MAX(desc.width.value+desc.borderLeft.value+desc.borderRight.value, 0),
                               MAX(desc.height.value+desc.borderTop.value+desc.borderBottom.value, 0));

    [control setNeedsLayout];
}

@end
