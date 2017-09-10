#import "AGCodeScannerDesc+XML.h"
#import "AGButtonDesc+XML.h"
#import "AGForm+XML.h"

@implementation AGCodeScannerDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // form
    AGForm *formDesc = [[AGForm alloc] initWithXML:node];
    self.form = formDesc;
    [formDesc release];

    // code type
    NSString *jsonString = [node stringValueForXPath:@"@codetype"];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    if (jsonData) {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        for (NSString *key in jsonArray) {
            AGCodeType type = AGCodeTypeWithText(key);
            if (self.codeType == AGCodeTypeNone) {
                self.codeType = type;
            } else {
                self.codeType |= type;
            }
        }
    }

    return self;
}

@end
