#import "AGDropDownDesc+XML.h"
#import "AGPickerDesc+XML.h"
@implementation AGDropDownDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // list src
    self.listSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@listsrc"] ];
    
    // watermark
    self.watermark = [AGVariable variableWithText:[node stringValueForXPath:@"@watermark"] ];
    
    // item path
    if ([node hasNodeForXPath:@"@itempath"]) {
        self.itemPath = [node stringValueForXPath:@"@itempath"];
    } else {
        self.itemPath = @"$.*";
    }
    
    // text path
    if ([node hasNodeForXPath:@"@textpath"]) {
        self.textPath = [node stringValueForXPath:@"@textpath"];
    } else {
        self.textPath = @"$.text";
    }
    
    // value path
    if ([node hasNodeForXPath:@"@valuepath"]) {
        self.valuePath = [node stringValueForXPath:@"@valuepath"];
    } else {
        self.valuePath = @"$.value";
    }
    
    return self;
}

@end
