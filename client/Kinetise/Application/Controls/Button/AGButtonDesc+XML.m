#import "AGButtonDesc+XML.h"
#import "AGImageDesc+XML.h"

@implementation AGButtonDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // active border color
    if ([node hasNodeForXPath:@"@activebordercolor"]) {
        self.activeBorderColor = AGColorWithText([node stringValueForXPath:@"@activebordercolor"]);
    } else {
        self.activeBorderColor = self.borderColor;
    }

    // active src
    if ([node hasNodeForXPath:@"@activesrc"]) {
        self.activeSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@activesrc"] ];
    }

    // active http query params
    if ([node hasNodeForXPath:@"@activehttpparams"]) {
        self.activeHttpQueryParams = [AGHTTPQueryParams paramsWithJSONString:[node stringValueForXPath:@"@activehttpparams"] ];
    }

    // active http header params
    if ([node hasNodeForXPath:@"@activeheaderparams"]) {
        self.activeHttpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:[node stringValueForXPath:@"@activeheaderparams"] ];
    }

    // invalid src
    if ([node hasNodeForXPath:@"@invalidsrc"]) {
        self.invalidSrc = [AGVariable variableWithText:[node stringValueForXPath:@"@invalidsrc"] ];
    }

    // invalid http query params
    if ([node hasNodeForXPath:@"@invalidhttpparams"]) {
        self.invalidHttpQueryParams = [AGHTTPQueryParams paramsWithJSONString:[node stringValueForXPath:@"@invalidhttpparams"] ];
    }

    // invalid http header params
    if ([node hasNodeForXPath:@"@invalidheaderparams"]) {
        self.invalidHttpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:[node stringValueForXPath:@"@invalidheaderparams"] ];
    }

    return self;
}

@end
