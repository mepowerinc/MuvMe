#import "AGForm+XML.h"
#import "GDataXMLNode+XPath.h"
#import "AGValidationRule+JSON.h"

@implementation AGForm (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [self init];

    // form id
    self.formId = [AGVariable variableWithText:[node stringValueForXPath:@"@formid"] ];

    // initial value
    self.initialValue = [AGVariable variableWithText:[node stringValueForXPath:@"@initvalue"] ];

    // validation rules
    if ([node hasNodeForXPath:@"@validationrules"]) {
        NSData *jsonData = [[node stringValueForXPath:@"@validationrules"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        // rules
        for (NSDictionary *jsonDict in json[@"rules"]) {
            AGValidationRule *validationRule = [[AGValidationRule alloc] initWithJSON:jsonDict];
            [validationRules addObject:validationRule];
            [validationRule release];
        }
        
        // dependencies
        for (NSString *dependency in json[@"dependencies"]) {
            [dependencies addObject:dependency];
        }
    }

    return self;
}

@end
