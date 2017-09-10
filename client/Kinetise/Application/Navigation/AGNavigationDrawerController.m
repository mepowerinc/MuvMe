#import "AGNavigationDrawerController.h"
#import "AGOverlayController.h"
#import "AGOverlayDesc.h"
#import "AGOverlayDesc+Layout.h"
#import "AGScreenController.h"
#import "AGScreenDesc+Layout.h"
#import "AGLayoutManager.h"
#import "AGApplication.h"

static CGFloat const drawerBackgroundTransparency = 0.3f;
static CGFloat const drawerAnimationDuration = 0.2f;

@interface AGNavigationDrawerController ()<UIGestureRecognizerDelegate>{
    CGFloat offset;
    CGFloat baseOffset;
    BOOL isExpanded;
    UIView *backgroundView;
    UIView *statusBar;
}
@end

@implementation AGNavigationDrawerController

@synthesize delegate;
@synthesize mainController;
@synthesize panelController;
@synthesize panelPosition;
@synthesize shouldMoveScreen;
@synthesize shouldMoveOverlay;
@synthesize shouldGrayoutBackgroud;
@synthesize statusBar;

#pragma mark - Initialization

- (void)dealloc {
    self.mainController = nil;
    self.panelController = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // settings
    self.view.clipsToBounds = YES;
    self.panelPosition = drawerPanelPositionNone;
    
    // background
    backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    backgroundView.hidden = YES;
    
    // background tap
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBcg)];
    [backgroundView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    // status bar
    statusBar = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:statusBar];
    [statusBar release];
    statusBar.backgroundColor = [UIColor blackColor];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == panelController.view) return YES;
    return NO;
}

- (void)setMainController:(UIViewController *)mainController_ {
    if (mainController == mainController_) return;
    
    // remove
    if (mainController) {
        [mainController willMoveToParentViewController:nil];
        [mainController.view removeFromSuperview];
        [mainController removeFromParentViewController];
    }
    
    // set
    [mainController release];
    mainController = [mainController_ retain];
    
    // add
    if (mainController) {
        [self addChildViewController:mainController];
        [self.view insertSubview:mainController.view belowSubview:backgroundView];
        [mainController didMoveToParentViewController:self];
    }
}

- (void)setPanelController:(UIViewController *)panelController_ {
    if (panelController == panelController_) return;
    
    // set
    [panelController release];
    panelController = [panelController_ retain];
    
    // background tap
    if (panelController) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBcg)];
        [panelController.view addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        tapGestureRecognizer.delegate = self;
    }
}

- (void)onBcg {
    [self togglePanel];
}

- (void)showPanel {
    if (!panelController || isExpanded) return;
    
    [self togglePanel];
}

- (void)hidePanel {
    if (!panelController || !isExpanded) return;
    
    [self togglePanel];
}

- (void)togglePanel {
    if (!panelController || !self.view.userInteractionEnabled) return;
    
    // user interaction
    self.view.userInteractionEnabled = NO;
    
    // frame
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    // background
    if (shouldGrayoutBackgroud) {
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0;
    } else {
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        backgroundView.alpha = 1;
    }
    
    // animation
    CGFloat animationDuration = drawerAnimationDuration;
    
    if ( (shouldMoveOverlay == NO && shouldMoveScreen == NO) || panelPosition == drawerPanelPositionNone) {
        animationDuration = 0;
    }
    
    if (isExpanded) {
        if ([delegate respondsToSelector:@selector(navigationDrawerWillHidePanel:)]) {
            [delegate navigationDrawerWillHidePanel:self];
        }
        
        if (shouldGrayoutBackgroud) {
            backgroundView.alpha = drawerBackgroundTransparency;
        }
        
        [panelController willMoveToParentViewController:nil];
        
        if (shouldMoveScreen && !shouldMoveOverlay) {
            backgroundView.frame = [self movedMainFrame];
        } else {
            backgroundView.frame = [self normalMainFrame];
        }
        
        panelController.view.frame = [self movedPanelFrame];
        if (shouldMoveScreen) {
            mainController.view.frame = [self movedMainFrame];
        } else {
            mainController.view.frame = [self normalMainFrame];
        }
        
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            backgroundView.frame = [self normalMainFrame];
            
            if (shouldMoveOverlay) {
                panelController.view.frame = [self normalPanelFrame];
            } else {
                panelController.view.frame = [self movedPanelFrame];
            }
            mainController.view.frame = [self normalMainFrame];
            
            if (shouldGrayoutBackgroud) {
                backgroundView.alpha = 0;
            }
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
            
            [panelController.view removeFromSuperview];
            [panelController removeFromParentViewController];
            
            backgroundView.hidden = YES;
            
            if ([delegate respondsToSelector:@selector(navigationDrawerDidHidePanel:)]) {
                [delegate navigationDrawerDidHidePanel:self];
            }
        }];
    } else {
        if ([delegate respondsToSelector:@selector(navigationDrawerWillShowPanel:)]) {
            [delegate navigationDrawerWillShowPanel:self];
        }
        
        if (shouldGrayoutBackgroud) {
            backgroundView.alpha = 0;
        }
        
        [self addChildViewController:panelController];
        [self.view addSubview:panelController.view];
        
        if (shouldMoveScreen && !shouldMoveOverlay) {
            [self.view bringSubviewToFront:panelController.view];
            [self.view bringSubviewToFront:mainController.view];
            [self.view bringSubviewToFront:backgroundView];
        } else {
            [self.view bringSubviewToFront:mainController.view];
            [self.view bringSubviewToFront:backgroundView];
            [self.view bringSubviewToFront:panelController.view];
        }
        
        backgroundView.frame = [self normalMainFrame];
        
        if (shouldMoveOverlay) {
            panelController.view.frame = [self normalPanelFrame];
        } else {
            panelController.view.frame = [self movedPanelFrame];
        }
        mainController.view.frame = [self normalMainFrame];
        
        backgroundView.hidden = NO;
        
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (shouldMoveScreen && !shouldMoveOverlay) {
                backgroundView.frame = [self movedMainFrame];
            } else {
                backgroundView.frame = [self normalMainFrame];
            }
            panelController.view.frame = [self movedPanelFrame];
            if (shouldMoveScreen) {
                mainController.view.frame = [self movedMainFrame];
            } else {
                mainController.view.frame = [self normalMainFrame];
            }
            if (shouldGrayoutBackgroud) {
                backgroundView.alpha = drawerBackgroundTransparency;
            }
        } completion:^(BOOL finished){
            self.view.userInteractionEnabled = YES;
            
            [panelController didMoveToParentViewController:self];
            
            if ([delegate respondsToSelector:@selector(navigationDrawerDidShowPanel:)]) {
                [delegate navigationDrawerDidShowPanel:self];
            }
        }];
    }
    
    isExpanded = !isExpanded;
    
    [self.view bringSubviewToFront:statusBar];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // status bar
    statusBar.frame = [UIApplication sharedApplication].statusBarFrame;
    
    // frame
    backgroundView.frame = self.view.bounds;
    mainController.view.frame = self.view.bounds;
    panelController.view.frame = self.view.bounds;
    
    // overlay layout
    AGOverlayController *overlayController = (AGOverlayController *)panelController;
    AGOverlayDesc *overlayDesc = (AGOverlayDesc *)overlayController.presenter.descriptor;
    
    // frames
    if (overlayDesc.animation == overlayAnimationLeft || overlayDesc.animation == overlayAnimationRight) {
        baseOffset = overlayDesc.controlDesc.blockWidth;
    } else {
        baseOffset = overlayDesc.controlDesc.blockHeight+statusBar.bounds.size.height;
    }
    offset = overlayDesc.offset.value;
    
    if (shouldMoveScreen && !shouldMoveOverlay) {
        backgroundView.frame = [self movedMainFrame];
    } else {
        backgroundView.frame = [self normalMainFrame];
    }
    
    if (isExpanded) {
        panelController.view.frame = [self movedPanelFrame];
        if (shouldMoveScreen) {
            mainController.view.frame = [self movedMainFrame];
        } else {
            mainController.view.frame = [self normalMainFrame];
        }
    } else {
        if (shouldMoveOverlay) {
            panelController.view.frame = [self normalPanelFrame];
        } else {
            panelController.view.frame = [self movedPanelFrame];
        }
        mainController.view.frame = [self normalMainFrame];
    }
}

#pragma mark - Frames

- (CGRect)normalPanelFrame {
    CGRect frame = panelController.view.frame;
    
    switch (panelPosition) {
        case drawerPanelPositionLeft:
            frame.origin.x = -baseOffset+offset;
            break;
        case drawerPanelPositionRight:
            frame.origin.x = self.view.bounds.size.width-offset;
            break;
        case drawerPanelPositionTop:
            frame.origin.y = -baseOffset+offset;
            break;
        case drawerPanelPositionBottom:
            frame.origin.y = self.view.bounds.size.height-offset;
            break;
        default:
            break;
    }
    
    return frame;
}

- (CGRect)movedPanelFrame {
    CGRect frame = panelController.view.frame;
    
    switch (panelPosition) {
        case drawerPanelPositionLeft:
            frame.origin.x = 0;
            break;
        case drawerPanelPositionRight:
            frame.origin.x = self.view.bounds.size.width-baseOffset;
            break;
        case drawerPanelPositionTop:
            frame.origin.y = 0;
            break;
        case drawerPanelPositionBottom:
            frame.origin.y = self.view.bounds.size.height-baseOffset;
            break;
        default:
            break;
    }
    
    return frame;
}

- (CGRect)normalMainFrame {
    CGRect frame = mainController.view.frame;
    
    switch (panelPosition) {
        case drawerPanelPositionLeft:
            frame.origin.x = 0;
            break;
        case drawerPanelPositionRight:
            frame.origin.x = 0;
            break;
        case drawerPanelPositionTop:
            frame.origin.y = 0;
            break;
        case drawerPanelPositionBottom:
            frame.origin.y = 0;
            break;
        default:
            break;
    }
    
    return frame;
}

- (CGRect)movedMainFrame {
    CGRect frame = mainController.view.frame;
    
    switch (panelPosition) {
        case drawerPanelPositionLeft:
            frame.origin.x = baseOffset-offset;
            break;
        case drawerPanelPositionRight:
            frame.origin.x = -baseOffset+offset;
            break;
        case drawerPanelPositionTop:
            frame.origin.y = baseOffset-offset;
            break;
        case drawerPanelPositionBottom:
            frame.origin.y = -baseOffset+offset;
            break;
        default:
            break;
    }
    
    return frame;
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.mainController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    return [self.mainController shouldAutorotate];
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.mainController preferredStatusBarStyle];
}

@end
