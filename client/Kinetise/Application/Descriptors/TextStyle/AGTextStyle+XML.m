#import "AGTextStyle+XML.h"

@implementation AGTextStyle (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super init];
    
    NSString *xmlValue;
    
    // font size
    self.fontSize = AGSizeWithText([node stringValueForXPath:@"@fontsize"]);
    
    // text multiplier
    self.useTextMultiplier = [node booleanValueForXPath:@"@textmultiplier"];
    
    // font italic
    xmlValue = [node stringValueForXPath:@"@fontstyle"];
    if (![xmlValue isEqualToString:AG_NONE]) {
        self.isItalic = YES;
    }
    
    // font bold
    xmlValue = [node stringValueForXPath:@"@fontweight"];
    if (![xmlValue isEqualToString:AG_NONE]) {
        self.isBold = YES;
    }
    
    // text align
    self.textAlign = AGAlignWithText([node stringValueForXPath:@"@textalign"]);
    
    // text valign
    if ([node hasNodeForXPath:@"@textvalign"]) {
        self.textValign = AGValignWithText([node stringValueForXPath:@"@textvalign"]);
    }
    
    // text color
    self.textColor = AGColorWithText([node stringValueForXPath:@"@textcolor"]);
    self.textActiveColor = self.textColor;
    self.textInvalidColor = self.textColor;
    
    // text active color
    if ([node hasNodeForXPath:@"@activecolor"]) {
        self.textActiveColor = AGColorWithText([node stringValueForXPath:@"@activecolor"]);
    }
    
    // text invalid color
    if ([node hasNodeForXPath:@"@invalidcolor"]) {
        self.textInvalidColor = AGColorWithText([node stringValueForXPath:@"@invalidcolor"]);
    }
    
    // watermark color
    if ([node hasNodeForXPath:@"@watermarkcolor"]) {
        self.watermarkColor = AGColorWithText([node stringValueForXPath:@"@watermarkcolor"]);
    }
    
    // text underline
    xmlValue = [node stringValueForXPath:@"@textdecoration"];
    if (![xmlValue isEqualToString:AG_NONE]) {
        self.isUnderline = YES;
    }
    
    // text padding left
    self.textPaddingLeft = AGSizeWithText([node stringValueForXPath:@"@textpaddingleft"]);
    
    // text padding right
    self.textPaddingRight = AGSizeWithText([node stringValueForXPath:@"@textpaddingright"]);
    
    // text padding top
    self.textPaddingTop = AGSizeWithText([node stringValueForXPath:@"@textpaddingtop"]);
    
    // text padding bottom
    self.textPaddingBottom = AGSizeWithText([node stringValueForXPath:@"@textpaddingbottom"]);
    
    return self;
}

@end
