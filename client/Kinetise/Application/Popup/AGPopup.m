#import "AGPopup.h"
#import "AGControl.h"
#import "AGOverlay.h"

@implementation AGPopup

@synthesize control;

#pragma mark - Initialization

- (void)dealloc {
    self.control = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGPopupDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // control
    self.control = [AGControl controlWithDesc:descriptor_.controlDesc];
    [self addSubview:self.control];
    
    return self;
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];
    
    [control setupAssets];
}

- (void)loadAssets {
    [super loadAssets];
    
    [control loadAssets];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // layout control
    AGControlDesc *contentDesc = (AGControlDesc *)control.descriptor;
    
    control.frame = CGRectMake(contentDesc.positionX+contentDesc.marginLeft.value,
                               contentDesc.positionY+contentDesc.marginTop.value,
                               MAX(contentDesc.width.value+contentDesc.borderLeft.value+contentDesc.borderRight.value, 0),
                               MAX(contentDesc.height.value+contentDesc.borderTop.value+contentDesc.borderBottom.value, 0));
    
    [control setNeedsLayout];
}

@end
