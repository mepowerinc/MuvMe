#import "AGScreenController.h"
#import "AGLayoutManager.h"
#import "AGScreenDesc+Layout.h"
#import "AGApplication.h"
#import "UIView+FirstResponder.h"
#import <UIKit/UIViewController.h>

@implementation AGScreenController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AGScreenDesc *desc = (AGScreenDesc *)presenter.descriptor;
    
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // !!!: Force interface orientation, portrait screen after landscape
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (!([self supportedInterfaceOrientations]&(1<<orientation)) ) {
        if (UIInterfaceOrientationIsPortrait(orientation) ) {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
        } else {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        }
    }
    
    // status bar color
    AGAPPLICATION.rootController.statusBar.backgroundColor = [UIColor colorWithRed:desc.statusBarColor.r green:desc.statusBarColor.g blue:desc.statusBarColor.b alpha:desc.statusBarColor.a];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // first responder
    UIView *firstResponder = [self.view findFirstResponder];
    [firstResponder resignFirstResponder];
    
    // keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    AGScreenDesc *screenDesc = (AGScreenDesc *)presenter.descriptor;
    
    if (screenDesc.orientation == screenOrientationLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    } else if (screenDesc.orientation == screenOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Keyboard

- (AGControl *)findParentControl:(UIView *)view {
    if (!view) return nil;
    
    if ([view isKindOfClass:[AGControl class]]) {
        return (AGControl *)view;
    }
    
    UIView *parent = [self findParentControl:view.superview];
    if ([parent isKindOfClass:[AGControl class]]) {
        return (AGControl *)parent;
    }
    
    return nil;
}

- (UIScrollView *)findScrollViewSuperview:(UIView *)view {
    if (![view isDescendantOfView:AGAPPLICATION.currentScreen.body]) {
        return nil;
    }
    
    AGScreen *screen = (AGScreen *)presenter;
    
    return (UIScrollView *)screen.body.contentView;
}

- (void)keyboardWillShown:(NSNotification *)notification {
    // first responder
    UIView *firstResponder = [self.view findFirstResponder];
    firstResponder = [self findParentControl:firstResponder];
    if (!firstResponder) return;
    
    // scroll view
    keyboardScrollView = [self findScrollViewSuperview:firstResponder];
    if (!keyboardScrollView) return;
    
    // metrics
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGRect scrollViewRect = [self.view convertRect:keyboardScrollView.frame fromView:keyboardScrollView.superview];
    CGRect hiddenScrollViewRect = CGRectIntersection(scrollViewRect, keyboardRect);
    
    // insets
    if (!CGRectIsNull(hiddenScrollViewRect) ) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, hiddenScrollViewRect.size.height, 0);
        keyboardScrollView.contentInset = contentInsets;
        keyboardScrollView.scrollIndicatorInsets = contentInsets;
    }
    
    // scroll
    NSInteger maxVisibleSpace = keyboardScrollView.bounds.size.height;
    CGRect visibleRect = firstResponder.frame;
    visibleRect = [keyboardScrollView convertRect:visibleRect fromView:firstResponder.superview];
    if (visibleRect.size.height > maxVisibleSpace) {
        visibleRect = CGRectMake(visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, maxVisibleSpace);
    }
    
    [keyboardScrollView scrollRectToVisible:visibleRect animated:NO];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Works only if there is no [contentView resignFirstResponder]; before [nextForm becomeFirstResponder];
    
    // hide
    keyboardScrollView.contentInset = UIEdgeInsetsZero;
    keyboardScrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    // FIX: iOS bug
    [keyboardScrollView setContentOffset:keyboardScrollView.contentOffset animated:NO];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    AGScreenDesc *desc = (AGScreenDesc *)presenter.descriptor;
    
    return desc.statusBarLightMode ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

@end
