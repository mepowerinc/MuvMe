#import "AGImageDesc+XML.h"
#import "AGTextDesc+XML.h"

@implementation AGImageDesc (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];
    
    // src
    if ([node hasNodeForXPath:@"@src"]) {
        self.src = [AGVariable variableWithText:[node stringValueForXPath:@"@src"] ];
    }
    
    // http query params
    if ([node hasNodeForXPath:@"@httpparams"]) {
        self.httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:[node stringValueForXPath:@"@httpparams"] ];
    }
    
    // http header params
    if ([node hasNodeForXPath:@"@headerparams"]) {
        self.httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:[node stringValueForXPath:@"@headerparams"] ];
    }
    
    // size mode
    self.sizeMode = AGSizeModeWithText([node stringValueForXPath:@"@sizemode"]);
    
    // show loading
    if ([node hasNodeForXPath:@"@showloading"]) {
        self.showLoading = [node booleanValueForXPath:@"@showloading"];
    }
    
    return self;
}

@end
