#import "AGPresenter.h"
#import "AGApplication+Control.h"
#import "UIView+FirstResponder.h"
#import "AGSignatureCanvas.h"
#import "AGControl.h"
#import "AGLayoutManager.h"

@implementation AGPresenter

- (void)dealloc {
    [feedLoader release];
    [super dealloc];
}

- (id)initWithDesc:(AGPresenterDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];
    
    // feed loader
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    [AGAPPLICATION getFeedControlsDesc:descriptor_ withArray:feeds];
    feedLoader = [[AGFeedLoader alloc] initWithFeeds:feeds];
    [feeds release];
    
    // gesture recognizer
    bcgTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBcgTap)];
    bcgTapGestureRecognizer.cancelsTouchesInView = NO;
    bcgTapGestureRecognizer.delaysTouchesEnded = NO;
    bcgTapGestureRecognizer.delaysTouchesBegan = NO;
    bcgTapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:bcgTapGestureRecognizer];
    [bcgTapGestureRecognizer release];
    bcgTapGestureRecognizer.delegate = self;
    
    return self;
}

- (void)refresh {
    // layout descriptors
    [AGLAYOUTMANAGER layout:(id < AGLayoutProtocol >)descriptor];
    
    // layout views
    [self setNeedsLayout];
    
    // force layout
    [self layoutIfNeeded];
}

- (void)reload {
    // execute variables
    [descriptor executeVariables];
    
    // update
    [descriptor update];
    
    // layout descriptors
    [AGLAYOUTMANAGER layout:(id < AGLayoutProtocol >)descriptor];
    
    // layout views
    [self setNeedsLayout];
    
    // setup assets
    [self setupAssets];
    
    // load assets
    [self loadAssets];
    
    // load feeds
    [self loadFeeds];
    
    // force layout
    [self layoutIfNeeded];
}

- (void)loadFeeds {
    [feedLoader loadFeeds];
}

- (void)reloadFeeds {
    [feedLoader reloadFeeds];
}

- (void)loadNextFeedPage:(id<AGFeedClientProtocol>)feedClient {
    [feedLoader loadNextFeedPage:feedClient];
}

- (void)onBcgTap {
    UIView *firstResponder = [self findFirstResponder];
    
    if (firstResponder) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [firstResponder resignFirstResponder];
        });
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (AGControl *)findParentControl:(UIView *)view {
    if (!view) return nil;
    
    if ([view isKindOfClass:[AGControl class]]) {
        return (AGControl *)view;
    }
    
    return [self findParentControl:view.superview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == bcgTapGestureRecognizer) {
        AGControl *control = [self findParentControl:touch.view];
        
        if ( (control && [control canBecomeFirstResponder]) || [touch.view isKindOfClass:[UIControl class]] || [NSStringFromClass([touch.view class]) hasPrefix:@"UITableViewCell"]) return NO;
    }
    
    return YES;
}

@end
