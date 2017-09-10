#import "AGOfflineReaderFeedXMLOperation.h"
#import "GDataXMLNode+XPath.h"
#import "NSString+HTML.h"

@implementation AGOfflineReaderFeedXMLOperation

- (void)parseFeed:(NSData *)data {
    GDataXMLDocument *xml = [[[GDataXMLDocument alloc] initWithData:data options:0 error:0] autorelease];
    if (!xml) {
        [self onFail:nil];
        return;
    }

    if (self.isCancelled) return;

    // children
    NSMutableArray *result = [NSMutableArray array];
    NSArray *children = json[@"nodes"];
    NSDictionary *namespaces = json[@"xmlns"];
    NSString *itemPath = json[@"itemPath"];
    NSDictionary *usingFields = json[@"usingFields"];

    for (NSMutableDictionary *child in children) {
        NSString *usingField = child[@"usingFieldInParent"];
        NSString *xPath = usingFields[usingField];

        NSArray *items = [xml.rootElement nodesForXPath:itemPath namespaces:namespaces error:nil];
        for (GDataXMLNode *item in items) {
            NSArray *nodes = [item nodesForXPath:xPath namespaces:namespaces error:nil];
            if (nodes.count) {
                NSString *uri = [nodes[0] stringValue];

                if ([child[@"dataType"] isEqualToString:@"IMAGE"]) {
                    uri = [uri stringByExtractingIMGFromHTML];
                } else {
                    uri = [uri stringByExtractingURLFromHTML];
                }

                NSMutableDictionary *newChild = [child mutableCopy];
                newChild[@"httpUrl"] = uri;
                [result addObject:newChild];
                [newChild release];
            }
        }
    }

    if (self.isCancelled) return;

    // success
    [self onSuccess:result];
}

@end
