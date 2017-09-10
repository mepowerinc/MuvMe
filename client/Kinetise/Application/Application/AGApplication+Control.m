#import "AGApplication+Control.h"
#import "AGFormClientProtocol.h"
#import "AGContainerDesc.h"
#import "AGContainer.h"
#import "AGSearchInputDesc.h"
#import "AGSearchInput.h"
#import "NSObject+Nil.h"
#import "AGEditableText.h"
#import "AGDataFeed.h"

@implementation AGApplication (Control)

#pragma mark - Control Parent

- (BOOL)isControl:(AGControlDesc *)controlDesc liesOnScreen:(AGScreenDesc *)screenDesc {
    if (screenDesc.header == controlDesc.section) return YES;
    if (screenDesc.body == controlDesc.section) return YES;
    if (screenDesc.naviPanel == controlDesc.section) return YES;

    return NO;
}

- (BOOL)isControl:(AGControlDesc *)controlDesc liesOnControlOfType:(Class)parentClass {
    if ([controlDesc.parent isKindOfClass:parentClass]) {
        return YES;
    } else {
        if (controlDesc.parent) [self isControl:controlDesc.parent liesOnControlOfType:parentClass];
    }

    return NO;
}

#pragma mark - View

- (AGView *)getViewWithDesc:(AGDesc *)desc {
    AGView *result = nil;

    result = [self findView:desc inParent:currentScreen];
    if (!result) result = [self findView:desc inParent:currentOverlay];

    return result;
}

- (AGView *)findView:(AGDesc *)desc inParent:(AGView *)parent {
    if (!desc) return nil;

    AGView *result = nil;

    if (parent.descriptor == desc) {
        return parent;
    }

    if ([parent isKindOfClass:[AGOverlay class]]) {
        AGOverlay *overlay = (AGOverlay *)parent;
        result = [self findView:desc inParent:overlay.control];
    } else if ([parent isKindOfClass:[AGScreen class]]) {
        AGScreen *screen = (AGScreen *)parent;
        result = [self findView:desc inParent:screen.header];
        if (!result) result = [self findView:desc inParent:screen.body];
        if (!result) result = [self findView:desc inParent:screen.naviPanel];
    } else if ([parent isKindOfClass:[AGSection class]]) {
        AGSection *section = (AGSection *)parent;
        if (section.descriptor == desc) {
            result = section;
        }
        if (!result) {
            for (AGView *control in section.controls) {
                if (!result) result = [self findView:desc inParent:control];
            }
        }
    } else if ([parent isKindOfClass:[AGContainer class]]) {
        AGContainer *container = (AGContainer *)parent;
        if (container.descriptor == desc) {
            result = container;
        }
        if (!result) {
            for (AGView *control in container.controls) {
                if (!result) result = [self findView:desc inParent:control];
            }
        }
    } else if ([parent isKindOfClass:[AGControl class]]) {
        AGControl *control = (AGControl *)parent;
        if (control.descriptor == desc) {
            result = control;
        }
    }

    return result;
}

#pragma mark - Control Desc

- (AGControlDesc *)getControlDesc:(NSString *)controlId {
    AGControlDesc *result = nil;

    if (!result) result = [self getControlDesc:controlId withParent:currentScreenDesc];
    if (!result) result = [self getControlDesc:controlId withParent:currentOverlayDesc];

    return result;
}

- (AGControlDesc *)getControlDesc:(NSString *)controlId withParent:(AGDesc *)parentDesc {
    if (isEmpty(controlId) ) return nil;

    AGControlDesc *result = nil;

    if ([parentDesc isKindOfClass:[AGScreenDesc class]]) {
        AGScreenDesc *screenDesc = (AGScreenDesc *)parentDesc;
        if (!result) result = [self getControlDesc:controlId withParent:screenDesc.header];
        if (!result) result = [self getControlDesc:controlId withParent:screenDesc.body];
        if (!result) result = [self getControlDesc:controlId withParent:screenDesc.naviPanel];
    } else if ([parentDesc isKindOfClass:[AGOverlayDesc class]]) {
        AGOverlayDesc *overlayDesc = (AGOverlayDesc *)parentDesc;
        if (!result) result = [self getControlDesc:controlId withParent:overlayDesc.controlDesc];
    } else if ([parentDesc isKindOfClass:[AGSectionDesc class]]) {
        AGSectionDesc *sectionDesc = (AGSectionDesc *)parentDesc;
        for (AGDesc *child in sectionDesc.children) {
            if (!result) result = [self getControlDesc:controlId withParent:child];
        }
    } else if ([parentDesc isKindOfClass:[AGContainerDesc class]]) {
        AGContainerDesc *containerDesc = (AGContainerDesc *)parentDesc;
        if ([controlId isEqualToString:((AGControlDesc *)parentDesc).identifier]) {
            result = (AGControlDesc *)parentDesc;
        }
        if (!result) {
            for (AGDesc *child in containerDesc.children) {
                if (!result) result = [self getControlDesc:controlId withParent:child];
            }
        }
    } else if ([parentDesc isKindOfClass:[AGControlDesc class]]) {
        if ([controlId isEqualToString:((AGControlDesc *)parentDesc).identifier]) {
            result = (AGControlDesc *)parentDesc;
        }
    }

    return result;
}

#pragma mark - Control

- (AGControl *)getControl:(NSString *)controlId {
    AGControl *result = nil;

    if (!result) result = [self getControl:controlId withParent:currentScreen];
    if (!result) result = [self getControl:controlId withParent:currentOverlay];

    return result;
}

- (AGControl *)getControl:(NSString *)controlId withParent:(AGView *)parent {
    if (isEmpty(controlId) ) return nil;

    AGControl *result = nil;

    if ([parent isKindOfClass:[AGScreen class]]) {
        AGScreen *screen = (AGScreen *)parent;
        if (!result) result = [self getControl:controlId withParent:screen.header];
        if (!result) result = [self getControl:controlId withParent:screen.body];
        if (!result) result = [self getControl:controlId withParent:screen.naviPanel];
    } else if ([parent isKindOfClass:[AGOverlay class]]) {
        AGOverlay *overlay = (AGOverlay *)parent;
        if (!result) result = [self getControl:controlId withParent:overlay.control];
    } else if ([parent isKindOfClass:[AGSection class]]) {
        AGSection *section = (AGSection *)parent;
        for (AGControl *child in section.controls) {
            if (!result) result = [self getControl:controlId withParent:child];
        }
    } else if ([parent isKindOfClass:[AGContainer class]]) {
        AGContainer *container = (AGContainer *)parent;
        AGContainerDesc *containerDesc = (AGContainerDesc *)container.descriptor;

        if ([controlId isEqualToString:containerDesc.identifier]) {
            result = (AGControl *)parent;
        }
        if (!result) {
            for (AGControl *child in container.controls) {
                if (!result) result = [self getControl:controlId withParent:child];
            }
        }
    } else if ([parent isKindOfClass:[AGControl class]]) {
        AGControl *control = (AGControl *)parent;
        AGControlDesc *controlDesc = (AGControlDesc *)control.descriptor;

        if ([controlId isEqualToString:controlDesc.identifier]) {
            result = (AGControl *)parent;
        }
    }

    return result;
}

- (AGControl *)getControlWithDesc:(AGControlDesc *)controlDesc_ {
    AGControl *result = nil;
    
    if (!result) result = [self getControlWithDesc:controlDesc_ andParent:currentScreen];
    if (!result) result = [self getControlWithDesc:controlDesc_ andParent:currentOverlay];
    
    return result;
}

- (AGControl *)getControlWithDesc:(AGControlDesc *)controlDesc_ andParent:(AGView *)parent {
    if (!controlDesc_) return nil;
    
    AGControl *result = nil;
    
    if ([parent isKindOfClass:[AGScreen class]]) {
        AGScreen *screen = (AGScreen *)parent;
        if (!result) result = [self getControlWithDesc:controlDesc_ andParent:screen.header];
        if (!result) result = [self getControlWithDesc:controlDesc_ andParent:screen.body];
        if (!result) result = [self getControlWithDesc:controlDesc_ andParent:screen.naviPanel];
    } else if ([parent isKindOfClass:[AGOverlay class]]) {
        AGOverlay *overlay = (AGOverlay *)parent;
        if (!result) result = [self getControlWithDesc:controlDesc_ andParent:overlay.control];
    } else if ([parent isKindOfClass:[AGSection class]]) {
        AGSection *section = (AGSection *)parent;
        for (AGControl *child in section.controls) {
            if (!result) result = [self getControlWithDesc:controlDesc_ andParent:child];
        }
    } else if ([parent isKindOfClass:[AGContainer class]]) {
        AGContainer *container = (AGContainer *)parent;
        AGContainerDesc *containerDesc = (AGContainerDesc *)container.descriptor;
        
        if (controlDesc_==containerDesc) {
            result = (AGControl *)parent;
        }
        if (!result) {
            for (AGControl *child in container.controls) {
                if (!result) result = [self getControlWithDesc:controlDesc_ andParent:child];
            }
        }
    } else if ([parent isKindOfClass:[AGControl class]]) {
        AGControl *control = (AGControl *)parent;
        AGControlDesc *controlDesc = (AGControlDesc *)control.descriptor;
        
        if (controlDesc_==controlDesc) {
            result = (AGControl *)parent;
        }
    }
    
    return result;
}

#pragma mark - Form

- (void)getFormControlsDesc:(AGDesc *)desc withArray:(NSMutableArray *)array {
    if (!desc) return;

    if ([desc conformsToProtocol:@protocol(AGFormClientProtocol)] && ![desc isKindOfClass:[AGSearchInputDesc class]]) {
        [array addObject:desc];
    } else if ([desc isKindOfClass:[AGScreenDesc class]]) {
        AGScreenDesc *screenDesc = (AGScreenDesc *)desc;
        [self getFormControlsDesc:screenDesc.header withArray:array];
        [self getFormControlsDesc:screenDesc.body withArray:array];
        [self getFormControlsDesc:screenDesc.naviPanel withArray:array];
    } else if ([desc isKindOfClass:[AGOverlayDesc class]]) {
        AGOverlayDesc *overlayDesc = (AGOverlayDesc *)desc;
        [self getFormControlsDesc:overlayDesc.controlDesc withArray:array];
    } else if ([desc isKindOfClass:[AGSectionDesc class]]) {
        AGSectionDesc *sectionDesc = (AGSectionDesc *)desc;
        for (AGDesc *child in sectionDesc.children) {
            [self getFormControlsDesc:child withArray:array];
        }
    } else if ([desc isKindOfClass:[AGContainerDesc class]]) {
        AGContainerDesc *containerDesc = (AGContainerDesc *)desc;
        for (AGDesc *child in containerDesc.children) {
            [self getFormControlsDesc:child withArray:array];
        }
    }
}

- (void)getFormControls:(AGView *)control withArray:(NSMutableArray *)array {
    id<AGFormClientProtocol> controlDesc = (id<AGFormClientProtocol>)control.descriptor;

    if ([controlDesc conformsToProtocol:@protocol(AGFormClientProtocol)] && ![controlDesc isKindOfClass:[AGSearchInput class]]) {
        [array addObject:control];
    } else if ([control isKindOfClass:[AGScreen class]]) {
        AGScreen *screen = (AGScreen *)control;
        [self getFormControls:screen.header withArray:array];
        [self getFormControls:screen.body withArray:array];
        [self getFormControls:screen.naviPanel withArray:array];
    } else if ([control isKindOfClass:[AGOverlay class]]) {
        AGOverlay *overlay = (AGOverlay *)control;
        [self getFormControls:overlay.control withArray:array];
    } else if ([control isKindOfClass:[AGSection class]]) {
        AGSection *section = (AGSection *)control;
        for (AGView *childControl in section.controls) {
            [self getFormControls:childControl withArray:array];
        }
    } else if ([control isKindOfClass:[AGContainer class]]) {
        AGContainer *container = (AGContainer *)control;
        for (AGView *childControl in container.controls) {
            [self getFormControls:childControl withArray:array];
        }
    }
}

#pragma mark - Feed

- (void)getFeedControlsDesc:(AGDesc *)desc withArray:(NSMutableArray *)array {
    if (!desc) return;

    if ([desc conformsToProtocol:@protocol(AGFeedClientProtocol)]) {
        [array addObject:desc];
    } else if ([desc isKindOfClass:[AGScreenDesc class]]) {
        AGScreenDesc *screenDesc = (AGScreenDesc *)desc;
        [self getFeedControlsDesc:screenDesc.header withArray:array];
        [self getFeedControlsDesc:screenDesc.body withArray:array];
        [self getFeedControlsDesc:screenDesc.naviPanel withArray:array];
    } else if ([desc isKindOfClass:[AGOverlayDesc class]]) {
        AGOverlayDesc *overlayDesc = (AGOverlayDesc *)desc;
        [self getFeedControlsDesc:overlayDesc.controlDesc withArray:array];
    } else if ([desc isKindOfClass:[AGSectionDesc class]]) {
        AGSectionDesc *sectionDesc = (AGSectionDesc *)desc;
        for (AGDesc *child in sectionDesc.children) {
            [self getFeedControlsDesc:child withArray:array];
        }
    } else if ([desc isKindOfClass:[AGContainerDesc class]]) {
        AGContainerDesc *containerDesc = (AGContainerDesc *)desc;
        for (AGDesc *child in containerDesc.children) {
            [self getFeedControlsDesc:child withArray:array];
        }
    }
}

- (id<AGFeedClientProtocol>)getControlFeedParent:(AGControlDesc *)controlDesc {
    if ([controlDesc.parent conformsToProtocol:@protocol(AGFeedClientProtocol)]) {
        return (id<AGFeedClientProtocol>)controlDesc.parent;
    }

    if (!controlDesc.parent) return nil;

    return [self getControlFeedParent:controlDesc.parent];
}

#pragma mark - Other controls

- (void)getControlsOfType:(Class)className withParent:(AGView *)control withArray:(NSMutableArray *)array {
    if ([control isKindOfClass:className]) {
        [array addObject:control];
    } else if ([control isKindOfClass:[AGScreen class]]) {
        AGScreen *screen = (AGScreen *)control;
        [self getControlsOfType:className withParent:screen.header withArray:array];
        [self getControlsOfType:className withParent:screen.body withArray:array];
        [self getControlsOfType:className withParent:screen.naviPanel withArray:array];
    } else if ([control isKindOfClass:[AGOverlay class]]) {
        AGOverlay *overlay = (AGOverlay *)control;
        [self getControlsOfType:className withParent:overlay.control withArray:array];
    } else if ([control isKindOfClass:[AGSection class]]) {
        AGSection *section = (AGSection *)control;
        for (AGView *childControl in section.controls) {
            [self getControlsOfType:className withParent:childControl withArray:array];
        }
    } else if ([control isKindOfClass:[AGContainer class]]) {
        AGContainer *container = (AGContainer *)control;
        for (AGView *childControl in container.controls) {
            [self getControlsOfType:className withParent:childControl withArray:array];
        }
    }
}

- (void)getInputControls:(AGView *)control withArray:(NSMutableArray *)array {
    if ([control isKindOfClass:[AGEditableText class]]) {
        [array addObject:control];
    } else if ([control isKindOfClass:[AGScreen class]]) {
        AGScreen *screen = (AGScreen *)control;
        [self getInputControls:screen.header withArray:array];
        [self getInputControls:screen.body withArray:array];
        [self getInputControls:screen.naviPanel withArray:array];
    } else if ([control isKindOfClass:[AGOverlay class]]) {
        AGOverlay *overlay = (AGOverlay *)control;
        [self getInputControls:overlay.control withArray:array];
    } else if ([control isKindOfClass:[AGSection class]]) {
        AGSection *section = (AGSection *)control;
        for (AGView *childControl in section.controls) {
            [self getInputControls:childControl withArray:array];
        }
    } else if ([control isKindOfClass:[AGContainer class]] && ![control isKindOfClass:[AGDataFeed class]]) {
        AGContainer *container = (AGContainer *)control;
        for (AGView *childControl in container.controls) {
            [self getInputControls:childControl withArray:array];
        }
    }
}

#pragma mark - Presenter

- (AGPresenterDesc *)getControlPresenterDesc:(AGControlDesc *)controlDesc {
    if (!controlDesc) return nil;

    if (!controlDesc.section) {
        return currentOverlayDesc;
    } else {
        return currentScreenDesc;
    }
}

- (AGPresenter *)getControlPresenter:(AGControl *)control {
    if (!control) return nil;

    AGControlDesc *controlDesc = (AGControlDesc *)control.descriptor;
    if (!controlDesc.section) {
        return currentOverlay;
    } else {
        return currentScreen;
    }
}

@end
