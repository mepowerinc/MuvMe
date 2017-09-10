#import "AGScreenDesc+XML.h"
#import "AGDesc+XML.h"
#import "AGBodyDesc+XML.h"
#import "AGSectionDesc+XML.h"

@implementation AGScreenDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // identifier
    self.screenId = [node stringValueForXPath:@"@id"];
    
    // atag
    self.atag = [node stringValueForXPath:@"@atag"];
    
    // background
    self.background = [AGVariable variableWithText:[node stringValueForXPath:@"@background"] ];
    
    // background video
    self.backgroundVideo = [AGVariable variableWithText:[node stringValueForXPath:@"@backgroundvideo"] ];
    
    // background color
    backgroundColor = AGColorWithText([node stringValueForXPath:@"@backgroundcolor"]);
    
    // background size mode
    self.backgroundSizeMode = AGSizeModeWithText([node stringValueForXPath:@"@backgroundsizemode"]);
    
    // body
    if ([node hasNodeForXPath:@"body"]) {
        AGBodyDesc *bodyDesc = [[AGBodyDesc alloc] initWithXML:[node nodeForXPath:@"body"] ];
        self.body = bodyDesc;
        [bodyDesc release];
    }
    
    // header
    if ([node hasNodeForXPath:@"header"]) {
        AGHeaderDesc *headerDesc = [[AGHeaderDesc alloc] initWithXML:[node nodeForXPath:@"header"] ];
        self.header = headerDesc;
        [headerDesc release];
    }
    
    // navipanel
    if ([node hasNodeForXPath:@"navipanel"]) {
        AGNaviPanelDesc *naviPanelDesc = [[AGNaviPanelDesc alloc] initWithXML:[node nodeForXPath:@"navipanel"] ];
        self.naviPanel = naviPanelDesc;
        [naviPanelDesc release];
    }
    
    // orientation
    self.orientation = AGScreenOrientationWithText([node stringValueForXPath:@"@orientation"]);
    
    // pull to refresh
    self.hasPullToRefresh = [node booleanValueForXPath:@"@pulltorefresh"];
    
    // protected
    if ([node hasNodeForXPath:@"@protected"]) {
        self.isProtected = [node booleanValueForXPath:@"@protected"];
    }
    
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
    
    // status bar color
    if ([node hasNodeForXPath:@"@statusbarcolor"]) {
        self.statusBarColor = AGColorWithText([node stringValueForXPath:@"@statusbarcolor"]);
    } else {
        self.statusBarColor = AGColorBlack();
    }
    
    // status bar mode
    if ([node hasNodeForXPath:@"@statusbarmode"]) {
        self.statusBarLightMode = [[node stringValueForXPath:@"@statusbarmode"] isEqualToString:@"light"];
    } else {
        self.statusBarLightMode = NO;
    }
    
    return self;
}

@end
