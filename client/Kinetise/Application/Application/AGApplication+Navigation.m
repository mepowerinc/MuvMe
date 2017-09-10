#import "AGApplication+Navigation.h"
#import "AGApplication+Overlay.h"
#import "AGApplication+Popup.h"
#import "AGUnits.h"
#import "AGAnalytics.h"
#import "AGGPSLocator.h"
#import "AGScreenController.h"
#import "AGLayoutManager.h"
#import "AGActionManager.h"
#import "AGScreenDesc+Layout.h"
#import "NSObject+Nil.h"

@interface AGApplication ()
@property(nonatomic, retain) AGHistoryData *protectedScreenData;
@property(nonatomic, retain) id currentContext;
@property(nonatomic, assign) BOOL isLoggedIn;
@end

@implementation AGApplication (Navigation)

- (void)setupScreen:(NSString *)screenId {
    [self setupScreen:screenId withTransition:transitionNone];
}

- (void)setupScreen:(NSString *)screenId withTransition:(AGTransition)transition {
    AGScreenDesc *screenDesc = [descriptor.screens objectForKey:screenId];
    if (!screenDesc) {
        NSLog(@"Error! Could not find screen: %@", screenId);
        isLoadingScreen = NO;
        return;
    }
    
    NSLog(@"screen: %@", screenId);
    
    [self invokeSetScreen:screenId animation:transition];
}

- (void)invokeSetScreen:(NSString *)screenId animation:(AGTransition)transition {
    // on exit
    if (currentScreenDesc.onExitAction) {
        [AGACTIONMANAGER executeAction:currentScreenDesc.onExitAction withSender:nil];
    }
    
    // close overlay
    [self hideOverlay];
    
    // close popups
    [AGAPPLICATION hidePopup];
    
    // clear screen
    currentScreen = nil;
    
    // screen descriptor
    AGScreenDesc *screenDesc = [descriptor.screens objectForKey:screenId];
    
    // current screen desc
    currentScreenDesc = screenDesc;
    
    // permissions
    if (currentScreenDesc.permissions&AGPermissionGPS) {
        [AGGPSLocator sharedInstance];
    }
    
    // analytics
    BOOL useAtag = YES;
    if ([currentContext isKindOfClass:[AGFeed class]]) {
        AGFeed *feed = (AGFeed *)currentContext;
        AGDSFeedItem *feedItemDataSource = feed.dataSource.items[feed.itemIndex];
        NSString *gid = feedItemDataSource.values[@"gid"];
        if (gid) {
            useAtag = NO;
            [[AGAnalytics sharedInstance] trackGoToScreen:gid];
        }
    }
    if (useAtag) {
        [[AGAnalytics sharedInstance] trackGoToScreen:currentScreenDesc.atag];
    }
    
    // execute variables
    [currentScreenDesc executeVariables];
    
    // update
    [currentScreenDesc update];
    
    // layout descriptors
    [AGLAYOUTMANAGER layout:currentScreenDesc withSize:[UIScreen mainScreen].bounds.size];
    
    // current screen
    currentScreen = [[AGScreen alloc] initWithDesc:screenDesc];
    
    // on enter
    if (currentScreenDesc.onEnterAction) {
        [AGACTIONMANAGER executeAction:currentScreenDesc.onEnterAction withSender:nil];
    }
    
    // screen view controller
    AGScreenController *screenViewController = [[AGScreenController alloc] initWithNibName:nil bundle:nil];
    screenViewController.presenter = currentScreen;
    
    // layout views
    [currentScreen setNeedsLayout];
    
    // setup assets
    [currentScreen setupAssets];
    
    // load assets
    [currentScreen loadAssets];
    
    // show
    NSArray *controllers = [[NSArray alloc] initWithObjects:screenViewController, nil];
    [screenViewController release];
    navigationController.transition = transition;
    [navigationController setViewControllers:controllers animated:transition != transitionNone];
    [controllers release];
    
    // loadg feeds
    [currentScreen loadFeeds];
    
    // end
    isLoadingScreen = NO;
    
    // clear
    [currentScreen release];
}

- (void)goToScreen:(NSString *)screenId {
    [self goToScreen:screenId withTransition:transitionNone];
}

- (void)goToScreen:(NSString *)screenId withTransition:(AGTransition)transition {
    [self goToScreen:screenId withContext:nil alterApiContext:nil guidContext:nil andTransition:transition];
}

- (void)goToScreen:(NSString *)screenId withContext:(id)context alterApiContext:(NSString *)alterApiContext_ guidContext:(NSString *)guidContext_ andTransition:(AGTransition)transition {
    if (isLoadingScreen) return;
    isLoadingScreen = YES;
    
    // screen desc
    AGScreenDesc *screenDesc = descriptor.screens[screenId];
    
    // reset state
    if (context) {
        [screenDesc resetState];
    }
    
    // protected
    if (screenDesc.isProtected && !self.isLoggedIn) {
        // save protected screen
        self.protectedScreenData = [[[AGHistoryData alloc] init] autorelease];
        protectedScreenData.screenId = screenId;
        protectedScreenData.context = context;
        protectedScreenData.alterApiContext = alterApiContext_;
        protectedScreenData.guidContext = guidContext_;
        
        // add protected login screen to stack temporarly
        AGHistoryData *historyData = [[AGHistoryData alloc] init];
        historyData.screenId = descriptor.protectedLoginScreen.value;
        historyData.context = nil;
        historyData.alterApiContext = nil;
        historyData.guidContext = nil;
        [screenStack addObject:historyData];
        [historyData release];
        
        // push protected login screen
        self.currentContext = nil;
        self.alterApiContext = nil;
        self.guidContext = nil;
        [self setupScreen:descriptor.protectedLoginScreen.value withTransition:transition];
        
        return;
    }
    
    // pop temporary protected login screen
    AGHistoryData *historyData = screenStack.lastObject;
    if ([historyData.screenId isEqualToString:descriptor.protectedLoginScreen.value]) {
        [screenStack removeLastObject];
    }
    
    // should add to stack
    BOOL shouldAddHistory = YES;
    if ([screenId isEqualToString:descriptor.startScreen.value]) shouldAddHistory = NO;
    if ([screenId isEqualToString:currentScreenDesc.screenId]) {
        if (alterApiContext && alterApiContext_ && [alterApiContext isEqualToString:alterApiContext_]) shouldAddHistory = NO;
        if (!alterApiContext && !alterApiContext_) shouldAddHistory = NO;
        if (guidContext && guidContext_ && [guidContext isEqualToString:guidContext_]) shouldAddHistory = NO;
        if (!guidContext && !guidContext_) shouldAddHistory = NO;
        if (alterApiContext && alterApiContext_ && ![alterApiContext isEqualToString:alterApiContext_]) shouldAddHistory = YES;
        if (guidContext && guidContext_ && ![guidContext isEqualToString:guidContext_]) shouldAddHistory = YES;
    }
    if ([screenId isEqualToString:descriptor.loginScreen.value]) shouldAddHistory = YES;
    
    // add screen to stack, keep max 10 screens in stack
    if (shouldAddHistory) {
        NSInteger startIndex = NSNotFound;
        for (int i = 0; i < screenStack.count; ++i) {
            AGHistoryData *historyData = screenStack[i];
            if (![historyData.screenId isEqualToString:descriptor.loginScreen.value]
                && ![historyData.screenId isEqualToString:descriptor.startScreen.value]
                && ![historyData.screenId isEqualToString:descriptor.mainScreen.value]
                ) {
                if (startIndex == NSNotFound) startIndex = i;
            }
        }
        
        if (startIndex == NSNotFound) {
            if (screenStack.count+1 > AG_MAX_SCREENS_HISTORY) {
                [screenStack removeObjectAtIndex:0];
            }
        } else {
            if (screenStack.count-startIndex+1 > AG_MAX_SCREENS_HISTORY) {
                [screenStack removeObjectAtIndex:startIndex];
            }
        }
        AGHistoryData *historyData = [[AGHistoryData alloc] init];
        historyData.screenId = screenId;
        historyData.context = context;
        historyData.alterApiContext = alterApiContext_;
        historyData.guidContext = guidContext_;
        [screenStack addObject:historyData];
        [historyData release];
    }
    
    self.currentContext = context;
    self.alterApiContext = alterApiContext_;
    self.guidContext = guidContext_;
    
    if (context) {
        [self setupScreen:screenId withTransition:transition];
    } else {
        [self setupScreen:screenId withTransition:transition];
    }
}

- (void)replaceScreen:(NSString *)screenId {
    [self replaceScreen:screenId withTransition:transitionNone];
}

- (void)replaceScreen:(NSString *)screenId withTransition:(AGTransition)transition {
    if (isLoadingScreen) return;
    isLoadingScreen = YES;
    
    // reset state
    if (currentContext) {
        AGScreenDesc *screenDesc = descriptor.screens[screenId];
        [screenDesc resetState];
    }
    
    // stack
    AGHistoryData *lastHistoryData = [screenStack lastObject];
    AGHistoryData *historyData = [[AGHistoryData alloc] init];
    historyData.screenId = screenId;
    historyData.context = lastHistoryData.context;
    historyData.alterApiContext = lastHistoryData.alterApiContext;
    historyData.guidContext = lastHistoryData.guidContext;
    [screenStack removeLastObject];
    [screenStack addObject:historyData];
    [historyData release];
    
    // set screen
    if (self.currentContext) {
        [self setupScreen:screenId withTransition:transition];
    } else {
        [self setupScreen:screenId withTransition:transition];
    }
}

- (void)setStartScreen {
    if (isNotEmpty(descriptor.startScreen.value) ) [self setScreen:descriptor.startScreen.value];
}

- (void)setLoginScreen {
    if (isNotEmpty(descriptor.loginScreen.value) ) [self setScreen:descriptor.loginScreen.value];
}

- (void)setScreen:(NSString *)screenId {
    if (!screenId || [currentScreenDesc.screenId isEqualToString:screenId]) return;
    
    [screenStack removeAllObjects];
    
    [self goToScreen:screenId withContext:nil alterApiContext:nil guidContext:nil andTransition:transitionNone];
}

- (void)goToProtectedScreen {
    if (!protectedScreenData) return;
    
    [self goToScreen:protectedScreenData.screenId withContext:protectedScreenData.context alterApiContext:protectedScreenData.alterApiContext guidContext:protectedScreenData.guidContext andTransition:transitionNone];
    self.protectedScreenData = nil;
}

#pragma mark - Back

- (BOOL)canBackToScreen:(NSString *)screenId {
    if ([screenId isEqualToString:descriptor.loginScreen.value]) {
        if (self.isLoggedIn) {
            return NO;
        }
    }
    
    return YES;
}

- (void)goToPreviousScreen {
    [self goToPreviousScreenWithTransition:transitionNone];
}

- (void)goToPreviousScreenWithTransition:(AGTransition)transition {
    if (screenStack.count > 1) {
        AGHistoryData *historyData = screenStack[screenStack.count-2];
        
        if ([self canBackToScreen:historyData.screenId]) {
            // reset state
            if (currentContext) {
                [currentScreenDesc resetState];
            }
            
            // stack
            [screenStack removeLastObject];
            self.currentContext = historyData.context;
            self.alterApiContext = historyData.alterApiContext;
            self.guidContext = historyData.guidContext;
            
            // screen
            [self setupScreen:historyData.screenId withTransition:transition];
        }
    }
}

- (void)backToScreen:(NSString *)screenId {
    [self backToScreen:screenId withTransition:transitionNone];
}

- (void)backToScreen:(NSString *)screenId withTransition:(AGTransition)transition {
    if ([screenId isEqualToString:currentScreenDesc.screenId]) {
        [screenStack removeLastObject];
    }
    
    while (screenStack.count >= 2) {
        AGHistoryData *currHistoryData = screenStack[screenStack.count-1];
        AGHistoryData *prevHistoryData = screenStack[screenStack.count-2];
        
        if ([currHistoryData.screenId isEqualToString:screenId]) {
            break;
        }
        
        if ([self canBackToScreen:prevHistoryData.screenId]) {
            [screenStack removeLastObject];
            if ([prevHistoryData.screenId isEqualToString:screenId]) {
                break;
            }
        } else {
            break;
        }
    }
    
    // reset state
    if (currentContext) {
        [currentScreenDesc resetState];
    }
    
    // stack
    AGHistoryData *historyData = [screenStack lastObject];
    self.currentContext = historyData.context;
    self.alterApiContext = historyData.alterApiContext;
    self.guidContext = historyData.guidContext;
    
    // screen
    [self setupScreen:historyData.screenId withTransition:transition];
}

- (void)backBySteps:(NSInteger)steps {
    [self backBySteps:steps withTransition:transitionNone];
}

- (void)backBySteps:(NSInteger)steps withTransition:(AGTransition)transition {
    while (screenStack.count >= 2 && steps > 0) {
        AGHistoryData *prevHistoryData = screenStack[screenStack.count-2];
        
        --steps;
        
        if ([self canBackToScreen:prevHistoryData.screenId]) {
            [screenStack removeLastObject];
        } else {
            break;
        }
    }
    
    // reset state
    if (currentContext) {
        [currentScreenDesc resetState];
    }
    
    // stack
    AGHistoryData *historyData = [screenStack lastObject];
    self.currentContext = historyData.context;
    self.alterApiContext = historyData.alterApiContext;
    self.guidContext = historyData.guidContext;
    
    // screen
    [self setupScreen:historyData.screenId withTransition:transition];
}

@end
