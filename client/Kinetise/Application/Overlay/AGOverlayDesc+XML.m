#import "AGOverlayDesc+XML.h"
#import "AGPopupDesc+XML.h"

@implementation AGOverlayDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // identifier
    self.overlayId = [node stringValueForXPath:@"@id"];

    // animation
    self.animation = AGOverlayAnimationWithText([node stringValueForXPath:@"@animation"]);

    // offset
    if ([node hasNodeForXPath:@"@offset"]) {
        self.offset = AGSizeWithText([node stringValueForXPath:@"@offset"]);
    } else {
        self.offset = AGSizeZero();
    }

    // move screen
    self.moveScreen = [node booleanValueForXPath:@"@movescreen"];

    // move overlay
    self.moveOverlay = [node booleanValueForXPath:@"@moveoverlay"];

    // background
    self.grayoutBackground = [node booleanValueForXPath:@"@grayoutbackground"];

    // on enter action
    if ([node hasNodeForXPath:@"@onenter"]) {
        self.onEnterAction = [AGAction actionWithText:[node stringValueForXPath:@"@onenter"] ];
    }

    // on exit action
    if ([node hasNodeForXPath:@"@onexit"]) {
        self.onExitAction = [AGAction actionWithText:[node stringValueForXPath:@"@onexit"] ];
    }

    // permissions
    if ([AGAction actionsRequireGPS:self.actions]) {
        self.permissions = AGPermissionGPS;
    }

    return self;
}

@end
