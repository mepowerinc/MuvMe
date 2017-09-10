#import "AGSection.h"
#import "AGControl.h"
#import "AGScrollView.h"

@implementation AGSection

@synthesize controls;
@synthesize contentView;

- (void)dealloc {
    [controls release];
    [super dealloc];
}

- (id)initWithDesc:(AGSectionDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // controls
    controls = [[NSMutableArray alloc] init];

    // content
    if (descriptor_.hasVerticalScroll) {
        contentView = [[AGScrollView alloc] initWithFrame:CGRectZero];
        [self addSubview:contentView];
        [contentView release];
    } else {
        contentView = self;
    }

    // controls
    for (AGDesc *childDesc in descriptor_.children) {
        [self addControl:[AGControl controlWithDesc:childDesc] ];
    }

    return self;
}

- (void)addControl:(AGControl *)control {
    [controls addObject:control];
    [contentView addSubview:control];
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    for (AGControl *control in controls) {
        [control setupAssets];
    }
}

- (void)loadAssets {
    [super loadAssets];

    for (AGControl *control in controls) {
        [control loadAssets];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGSectionDesc *desc = (AGSectionDesc *)descriptor;

    // content
    if (contentView != self) {
        contentView.frame = CGRectMake(0, 0, desc.width, desc.height);
        [contentView setNeedsLayout];
    }

    // controls
    for (AGControl *control in controls) {
        AGControlDesc *desc = (AGControlDesc *)control.descriptor;

        control.frame = CGRectMake(desc.positionX+desc.marginLeft.value,
                                   desc.positionY+desc.marginTop.value,
                                   MAX(desc.width.value+desc.borderLeft.value+desc.borderRight.value, 0),
                                   MAX(desc.height.value+desc.borderTop.value+desc.borderBottom.value, 0));

        [control setNeedsLayout];
    }
}

@end
