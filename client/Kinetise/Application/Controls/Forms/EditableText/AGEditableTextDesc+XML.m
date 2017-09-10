#import "AGEditableTextDesc+XML.h"
#import "AGControlDesc+XML.h"
#import "AGTextStyle+XML.h"
#import "AGForm+XML.h"

@implementation AGEditableTextDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];
    
    // watermark
    if ([node hasNodeForXPath:@"@watermark"]) {
        self.watermark.text = [AGVariable variableWithText:[node stringValueForXPath:@"@watermark"] ];
    } else {
        self.watermark = [AGVariable variableWithText:[node stringValue] ];
    }
    
    // text style
    self.textStyle = [[[AGTextStyle alloc] initWithXML:node] autorelease];
    
    // keyboard type
    self.keyboardType = AGKeyboardTypeWithText([node stringValueForXPath:@"@keyboard"]);
    
    // on accept
    if ([node hasNodeForXPath:@"@onaccept"]) {
        self.onAccept = [AGAction actionWithText:[node stringValueForXPath:@"@onaccept"] ];
    }
    
    // icon
    if ([node hasNodeForXPath:@"@decorationsrc"]) {
        self.iconSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@decorationsrc"] ];
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
