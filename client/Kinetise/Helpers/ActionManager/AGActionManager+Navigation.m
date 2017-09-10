#import "AGActionManager+Navigation.h"
#import <RMUniversalAlert/RMUniversalAlert.h>
#import "AGApplication+Navigation.h"
#import "AGApplication+Popup.h"
#import "AGApplication+Overlay.h"
#import "AGApplication+Control.h"
#import "NSObject+Nil.h"

@implementation AGActionManager (Navigation)

- (void)goToScreen:(id)sender :(id)object :(NSString *)screenId {
    [AGAPPLICATION goToScreen:screenId];
}

- (void)goToScreen:(id)sender :(id)object :(NSString *)screenId :(NSString *)transition {
    [AGAPPLICATION goToScreen:screenId withTransition:AGTransitionWithText(transition)];
}

- (void)goToPreviousScreen:(id)sender :(id)object {
    [AGAPPLICATION goToPreviousScreen];
}

- (void)goToPreviousScreen:(id)sender :(id)object :(NSString *)transition {
    [AGAPPLICATION goToPreviousScreenWithTransition:AGTransitionWithText(transition)];
}

- (void)backToScreen:(id)sender :(id)object :(NSString *)screenId {
    [AGAPPLICATION backToScreen:screenId];
}

- (void)backToScreen:(id)sender :(id)object :(NSString *)screenId :(NSString *)transition {
    [AGAPPLICATION backToScreen:screenId withTransition:AGTransitionWithText(transition)];
}

- (void)backBySteps:(id)sender :(id)object :(NSString *)screenIndex {
    [AGAPPLICATION backBySteps:[screenIndex integerValue]];
}

- (void)backBySteps:(id)sender :(id)object :(NSString *)screenIndex :(NSString *)transition {
    [AGAPPLICATION backBySteps:[screenIndex integerValue] withTransition:AGTransitionWithText(transition)];
}

- (void)goToScreenWithContext:(id)sender :(id)object :(NSString *)screenId :(id)context {
    [self goToScreenWithContext:sender :object :screenId :context :nil];
}

- (void)goToScreenWithContext:(id)sender :(id)object :(NSString *)screenId :(id)context :(NSString *)transition {
    NSString *alterApiContext = nil;
    NSString *guidContext = nil;
    
    // context
    if (!context) {
        NSLog(@"Error! 'goToScreenWithContext' context is missing!");
    } else {
        if ([context conformsToProtocol:@protocol(AGFeedClientProtocol)]) {
            id<AGFeedClientProtocol> feedClient = (id<AGFeedClientProtocol>)context;
            context = feedClient.feed;
            
            AGControlDesc *senderDesc = (AGControlDesc *)sender;
            feedClient.feed.itemIndex = senderDesc.itemIndex;
        }
        
        if ([context isKindOfClass:[AGFeed class]]) {
            AGFeed *feed = (AGFeed *)context;
            AGDSFeedItem *feedItemDataSource = feed.dataSource.items[feed.itemIndex];
            if (feedItemDataSource.alterApiContext) {
                alterApiContext = feedItemDataSource.alterApiContext;
            }
            if (feedItemDataSource.guid) {
                guidContext = feedItemDataSource.guid;
            }
        }
    }
    
    // go to screen
    [AGAPPLICATION goToScreen:screenId withContext:context alterApiContext:alterApiContext guidContext:guidContext andTransition:AGTransitionWithText(transition)];
}

- (void)goToProtectedScreen:(id)sender :(id)object {
    [AGAPPLICATION goToProtectedScreen];
}

- (void)previousElement:(id)sender :(id)object {
    [self previousElement:sender :object :nil];
}

- (void)previousElement:(id)sender :(id)object :(NSString *)transition {
    AGFeed *feed = AGAPPLICATION.currentContext;
    AGDSFeed *feedDataSource = feed.dataSource;
    
    NSString *screenId = nil;
    
    if (feedDataSource) {
        while (feed.itemIndex > 0 && !screenId) {
            --feed.itemIndex;
            AGDSFeedItem *feedItemDataSource = feedDataSource.items[feed.itemIndex];
            AGFeedItemTemplate *itemTemplate = feed.itemTemplates[feedItemDataSource.itemTemplateIndex];
            screenId = itemTemplate.detailScreenId;
        }
    }
    
    if (screenId) {
        [AGAPPLICATION replaceScreen:screenId withTransition:AGTransitionWithText(transition)];
    }
}

- (void)nextElement:(id)sender :(id)object {
    [self nextElement:sender :object :nil];
}

- (void)nextElement:(id)sender :(id)object :(NSString *)transition {
    AGFeed *feed = AGAPPLICATION.currentContext;
    AGDSFeed *feedDataSource = feed.dataSource;
    NSString *screenId = nil;
    
    if (feedDataSource) {
        while (feed.itemIndex < feedDataSource.items.count-1 && !screenId) {
            ++feed.itemIndex;
            AGDSFeedItem *feedItemDataSource = feedDataSource.items[feed.itemIndex];
            AGFeedItemTemplate *itemTemplate = feed.itemTemplates[feedItemDataSource.itemTemplateIndex];
            screenId = itemTemplate.detailScreenId;
        }
    }
    
    if (screenId) {
        [AGAPPLICATION replaceScreen:screenId withTransition:AGTransitionWithText(transition)];
    }
}

- (void)refresh:(id)sender :(id)object {
    [AGAPPLICATION.currentScreen reloadFeeds];
    [AGAPPLICATION.currentOverlay reloadFeeds];
}

- (void)reload:(id)sender :(id)object {
    [AGAPPLICATION reload];
}

- (void)closePopup:(id)sender :(id)object {
    [AGAPPLICATION hidePopup];
}

- (void)loadmore:(AGControlDesc *)sender :(id)object {
    AGControl *control = (AGControl *)[AGAPPLICATION getControl:sender.identifier];
    control.enabled = NO;
    
    [self performSelector:@selector(loadMore:) withObject:object afterDelay:0 inModes:@[NSRunLoopCommonModes]];
}

- (void)loadMore:(AGControlDesc<AGFeedClientProtocol> *)feedClient {
    AGControl *control = [AGAPPLICATION getControl:feedClient.identifier];
    AGPresenter *presenter = [AGAPPLICATION getControlPresenter:control];
    [presenter loadNextFeedPage:feedClient];
}

- (void)showOverlay:(id)sender :(id)object :(NSString *)overlayId {
    [AGAPPLICATION showOverlay:overlayId];
}

- (void)hideOverlay:(id)sender :(id)object {
    [AGAPPLICATION hideOverlay];
}

- (void)hideOverlayAndRefresh:(id)sender :(id)object {
    [AGAPPLICATION hideOverlay];
    [AGAPPLICATION.currentScreen reloadFeeds];
    [AGAPPLICATION.currentScreen reloadHeaderAndNaviPanel];
}

- (void)hideOverlayAndReload:(id)sender :(id)object {
    [AGAPPLICATION hideOverlay];
    [AGAPPLICATION.currentScreen reload];
}

- (void)showAlert:(id)sender :(id)object :(NSString *)title :(NSString *)message :(NSString *)closeButtonTile :(NSString *)closeButtonAction :(NSString *)otherButtonTitle :(NSString *)otherButtonAction {
    __block AGActionManager *weakSelf = self;
    
    [RMUniversalAlert showAlertInViewController:AGAPPLICATION.navigationController
                                      withTitle:title
                                        message:message
                              cancelButtonTitle:closeButtonTile
                         destructiveButtonTitle:nil
                              otherButtonTitles:(isEmpty(otherButtonTitle) ? nil : @[otherButtonTitle])
                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                                           if (buttonIndex == alert.cancelButtonIndex) {
                                               [weakSelf executeString:closeButtonAction withSender:sender];
                                           } else {
                                               [weakSelf executeString:otherButtonTitle withSender:sender];
                                           }
                                       }
     ];
}

@end
