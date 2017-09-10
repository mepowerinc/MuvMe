#import "AGApplicationDesc+XML.h"
#import "AGDesc+XML.h"
#import "AGScreenDesc+XML.h"
#import "AGOverlayDesc+XML.h"
#import "AGParser.h"

@implementation AGApplicationDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    NSString *xmlValue;

    // xml version
    self.xmlVersion = [node stringValueForXPath:@"applicationDescription/version"];

    // xml created version
    self.xmlCreatedVersion = [node stringValueForXPath:@"applicationDescription/createdVersion"];

    // api version
    self.apiVersion = [node stringValueForXPath:@"applicationDescription/apiVersion"];

    // name
    self.name = [node stringValueForXPath:@"applicationDescription/name"];

    // start screen
    self.startScreen = [AGVariable variableWithText:[node stringValueForXPath:@"applicationDescription/startScreen"] ];

    // login screen
    xmlValue = [node stringValueForXPath:@"applicationDescription/loginScreen"];
    if (![xmlValue isEqualToString:AG_NONE]) {
        self.loginScreen = [AGVariable variableWithText:[node stringValueForXPath:@"applicationDescription/loginScreen"] ];
    }

    // protected login screen
    if ([node hasNodeForXPath:@"applicationDescription/protectedLoginScreen"]) {
        xmlValue = [node stringValueForXPath:@"applicationDescription/protectedLoginScreen"];
        if (![xmlValue isEqualToString:AG_NONE]) {
            self.protectedLoginScreen = [AGVariable variableWithText:[node stringValueForXPath:@"applicationDescription/protectedLoginScreen"] ];
        }
    }

    // main screen
    self.mainScreen = [AGVariable variableWithText:[node stringValueForXPath:@"applicationDescription/mainScreen"] ];

    // default user agent
    self.defaultUserAgent = [node stringValueForXPath:@"applicationDescription/defaultUserAgent"];

    // min text multiplier
    self.minTextMultiplier = [node floatValueForXPath:@"applicationDescription/minTextMultiplier"];

    // max text multiplier
    self.maxTextMultiplier = [node floatValueForXPath:@"applicationDescription/maxTextMultiplier"];

    // validation color
    if ([node hasNodeForXPath:@"applicationDescription/validationErrorToastColor"]) {
        self.validationColor = AGColorWithText([node stringValueForXPath:@"applicationDescription/validationErrorToastColor"]);
    } else {
        self.validationColor = AGColorMake(1, 0, 0, 1);
    }

    // screens
    NSArray *screenNodes = [node nodesForXPath:@"application/screen"];
    for (GDataXMLNode *screenNode in screenNodes) {
        AGScreenDesc *screenDesc = [[AGScreenDesc alloc] initWithXML:screenNode];
        [screens setObject:screenDesc forKey:screenDesc.screenId];
        [screenDesc release];
    }
    
    // overlays
    NSArray *overlayNodes = [node nodesForXPath:@"overlays/overlay"];
    for (GDataXMLNode *overlayNode in overlayNodes) {
        AGOverlayDesc *overlayDesc = [[AGOverlayDesc alloc] initWithXML:overlayNode];
        [overlays setObject:overlayDesc forKey:overlayDesc.overlayId];
        [overlayDesc release];
    }
    
    // local storage
    NSArray *tableNodes = [node nodesForXPath:@"localstorage/tables/table"];
    for (GDataXMLNode *tableNode in tableNodes) {
        NSString *tableName = [tableNode stringValueForXPath:@"name"];
        NSString *tableSource = [tableNode stringValueForXPath:@"init/@src"];
        localStorage[tableName] = tableSource;
    }

    return self;
}

@end
