#import "AGContainer.h"
#import "AGContainerDesc.h"
#import "UIView+Debug.h"
#import "AGScrollView.h"
#import "AGLayoutManager.h"
#import "CGRect+Round.h"

@implementation AGContainer

@synthesize controls;

- (void)dealloc {
    [interLines release];
    [controls release];
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        [contentView removeObserver:self forKeyPath:@"contentOffset"];
    }
    [super dealloc];
}

- (id)initWithDesc:(AGContainerDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // controls
    controls = [[NSMutableArray alloc] init];

    // inter lines
    interLines = [[NSMutableArray alloc] init];

    // controls
    for (AGDesc *childDesc in descriptor_.children) {
        [self addControl:[AGControl controlWithDesc:childDesc] ];
    }

    // needs update scroll
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        shouldUpdateScrollView = YES;
        UIScrollView *scrollView = (UIScrollView *)contentView;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }

    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGContainerDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }

    // needs update scroll
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        shouldUpdateScrollView = YES;
    }

    // controls
    for (int i = 0; i < controls.count; ++i) {
        AGDesc *desc = descriptor_.children[i];
        AGControl *control = controls[i];
        control.descriptor = desc;
    }
}

#pragma mark - Lifecycle

- (Class)contentClass {
    AGContainerDesc *desc = (AGContainerDesc *)descriptor;

    if (desc.hasVerticalScroll || desc.hasHorizontalScroll) return [AGScrollView class];

    return [super contentClass];
}

#pragma mark - Controls

- (void)addControl:(AGControl *)control {
    control.parent = self;
    [controls addObject:control];
    [contentView addSubview:control];

    // inter lines
    AGContainerDesc *desc = (AGContainerDesc *)descriptor;
    if (desc.innerBorder.valueInUnits) {
        if (controls.count > 1) {
            UIView *interLine = [[UIView alloc] initWithFrame:CGRectZero];
            interLine.backgroundColor = [UIColor colorWithRed:desc.childrenSeparatorColor.r green:desc.childrenSeparatorColor.g blue:desc.childrenSeparatorColor.b alpha:desc.childrenSeparatorColor.a];
            [interLines addObject:interLine];
            [contentView addSubview:interLine];
            [interLine release];
            interLine.hidden = control.hidden;
        }
    }
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

    AGContainerDesc *desc = (AGContainerDesc *)descriptor;

    // controls
    for (AGControl *control in controls) {
        AGControlDesc *desc = (AGControlDesc *)control.descriptor;

        control.frame = CGRectMake(desc.positionX+desc.marginLeft.value,
                                   desc.positionY+desc.marginTop.value,
                                   MAX(desc.width.value+desc.borderLeft.value+desc.borderRight.value, 0),
                                   MAX(desc.height.value+desc.borderTop.value+desc.borderBottom.value, 0));

        [control setNeedsLayout];
    }

    // inter lines
    for (int i = 0; i < interLines.count; ++i) {
        UIView *interLine = interLines[i];
        AGControl *control = controls[i+1];

        switch (desc.containerLayout) {
        case layoutVertical:
            interLine.frame = CGRectMake(0, control.frame.origin.y-desc.innerBorder.value, desc.contentWidth, desc.innerBorder.value);
            break;
        case layoutHorizontal:
            interLine.frame = CGRectMake(control.frame.origin.x-desc.innerBorder.value, 0, desc.innerBorder.value, desc.contentHeight);
            break;
        default:
            break;
        }
    }

    // scroll
    if ([contentView isKindOfClass:[UIScrollView class] ]) {
        UIScrollView *scrollView = (UIScrollView *)contentView;
        scrollView.contentSize = CGSizeMake(desc.contentWidth, desc.contentHeight);

        if (shouldUpdateScrollView) {
            shouldUpdateScrollView = NO;
            CGFloat maxHorizontalContentOffset = MAX(scrollView.contentSize.width-scrollView.bounds.size.width, 0);
            CGFloat maxVerticalContentOffset = MAX(scrollView.contentSize.height-scrollView.bounds.size.height, 0);
            scrollView.contentOffset = CGPointMake(MIN(desc.horizontalScrollOffset, maxHorizontalContentOffset), MIN(desc.verticalScrollOffset, maxVerticalContentOffset) );
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView *)scrollView change:(NSDictionary *)change context:(void *)context {
    AGContainerDesc *desc = (AGContainerDesc *)descriptor;

    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
            desc.horizontalScrollOffset = scrollView.contentOffset.x;
            desc.verticalScrollOffset = MAX(scrollView.contentOffset.y, 0);
        }
    }
}

@end
