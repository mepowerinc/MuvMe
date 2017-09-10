#import "AGMapDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGFeed+XML.h"

@implementation AGMapDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // feed
    AGFeed *feedDesc = [[AGFeed alloc] initWithXML:node];
    self.feed = feedDesc;
    [feedDesc release];

    // pin size
    self.pinSize = AGSizeWithText(AG_PIN_SIZE);

    // geo data src
    if ([node hasNodeForXPath:@"@geodatasrc"]) {
        self.geoDataSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@geodatasrc"] ];
    }

    // x src
    self.xSrc = [AGVariable variableWithText:[NSString stringWithFormat:@"[d]regex(getControl('%@').getItemField('%@'), 'controltext');[/d]", self.identifier, [node stringValueForXPath:@"@longitude"]] ];

    // y src
    self.ySrc = [AGVariable variableWithText:[NSString stringWithFormat:@"[d]regex(getControl('%@').getItemField('%@'), 'controltext');[/d]", self.identifier, [node stringValueForXPath:@"@latitude"]] ];

    // pin src
    self.pinSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@pinimage"] ];

    // region
    self.region = AGMapRegionWithText([node stringValueForXPath:@"@initcameramode"]);

    // region radius
    self.regionRadius = [node floatValueForXPath:@"@initminradius"];

    // user location
    self.showUserLocation = [node booleanValueForXPath:@"@mylocationenabled"];

    // map popup
    if ([node hasNodeForXPath:@"@showmappopup"]) {
        self.showMapPopup = [node booleanValueForXPath:@"@showmappopup"];
    } else {
        self.showMapPopup = YES;
    }

    return self;
}

@end
