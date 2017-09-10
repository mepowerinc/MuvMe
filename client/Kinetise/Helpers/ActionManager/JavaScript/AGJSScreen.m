#import "AGJSScreen.h"
#import "AGFeed.h"
#import "AGApplication.h"
#import "AGActionManager+Navigation.h"

@implementation AGJSScreen

- (NSString *)name {
    return AGAPPLICATION.currentScreenDesc.atag;
}

- (NSDictionary *)context {
    if ([AGAPPLICATION.currentContext isKindOfClass:[AGFeed class]]) {
        AGFeed *feed = (AGFeed *)AGAPPLICATION.currentContext;
        AGDSFeedItem *feedItemDataSource = feed.dataSource.items[feed.itemIndex];
        return feedItemDataSource.values;
    }
    
    NSLog(@"Can't get screen context: %@", NSStringFromClass([AGAPPLICATION.currentContext class]) );
    
    return nil;
}

- (AGJSControl *)control:(NSString *)controlId {
    return [[[AGJSControl alloc] initWithControlId:controlId] autorelease];
}

- (void)go:(NSString *)screenId :(NSString *)transition {
    [AGACTIONMANAGER goToScreen:nil :nil :screenId :transition];
}

- (void)back:(id)screenIdOrStepsOrTransition :(NSString *)transition {
    if ([screenIdOrStepsOrTransition isKindOfClass:[NSNumber class]]) {
        [AGACTIONMANAGER backBySteps:nil :nil :[screenIdOrStepsOrTransition stringValue] :transition];
    } else if ([screenIdOrStepsOrTransition isKindOfClass:[NSString class]]) {
        if (AGTransitionWithText(screenIdOrStepsOrTransition) != transitionNone) {
            [AGACTIONMANAGER goToPreviousScreen:nil :nil :screenIdOrStepsOrTransition];
        } else {
            [AGACTIONMANAGER backToScreen:nil :nil :screenIdOrStepsOrTransition];
        }
    } else if (!screenIdOrStepsOrTransition) {
        [AGACTIONMANAGER goToPreviousScreen:nil :nil :transition];
    }
}

- (void)prev:(NSString *)transition {
    [AGACTIONMANAGER previousElement:nil :nil :transition];
}

- (void)next:(NSString *)transition {
    [AGACTIONMANAGER nextElement:nil :nil :transition];
}

- (void)refresh {
    [AGACTIONMANAGER refresh:nil :nil];
}

- (void)reload {
    [AGACTIONMANAGER reload:nil :nil];
}

@end
