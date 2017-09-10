#import "AGPickerDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGForm+XML.h"

@implementation AGPickerDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];
    
    // icon
    if ([node hasNodeForXPath:@"@decorationsrc"]) {
        self.iconSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@decorationsrc"] ];
    }
    
    // active icon
    if ([node hasNodeForXPath:@"@decorationactivesrc"]) {
        self.iconActiveSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@decorationactivesrc"] ];
    }
    
    // icon size mode
    if ([node hasNodeForXPath:@"@decorationsizemode"]) {
        self.iconSizeMode = AGSizeModeWithText([node stringValueForXPath:@"@decorationsizemode"]);
    }
    
    // icon width
    if ([node hasNodeForXPath:@"@decorationwidth"]) {
        self.iconWidth = AGSizeWithText([node stringValueForXPath:@"@decorationwidth"]);
    }
    
    // icon height
    if ([node hasNodeForXPath:@"@decorationheight"]) {
        self.iconHeight = AGSizeWithText([node stringValueForXPath:@"@decorationheight"]);
    }
    
    // icon align
    if ([node hasNodeForXPath:@"@decorationalign"]) {
        self.iconAlign = AGAlignWithText([node stringValueForXPath:@"@decorationalign"]);
    }
    
    // icon valign
    if ([node hasNodeForXPath:@"@decorationvalign"]) {
        self.iconValign = AGValignWithText([node stringValueForXPath:@"@decorationvalign"]);
    }
    
    return self;
}

@end
