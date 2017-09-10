#import "AGFeedItemTemplate+XML.h"
#import "AGDesc+XML.h"
#import "AGParser.h"
#import "NSObject+Nil.h"
#import "AGFeedRequiredField+JSON.h"
#import "AGContainerDesc.h"

@implementation AGFeedItemTemplate (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [super initWithXML:node];

    // required fields
    if (isNotEmpty([node stringValueForXPath:@"@requiredfields"]) ) {
        NSData *jsonData = [[node stringValueForXPath:@"@requiredfields"] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

        for (NSDictionary *jsonDict in jsonArray) {
            AGFeedRequiredField *requiredField = [[AGFeedRequiredField alloc] initWithJSON:jsonDict];
            [requiredFields addObject:requiredField];
            [requiredField release];
        }
    }

    // control
    GDataXMLNode *itemTemplateControlNode = node.children.firstObject;
    Class itemTemplateControlClass = [AGParser classWithName:itemTemplateControlNode.name];

    AGControlDesc *itemTemplateControlDesc = [[itemTemplateControlClass alloc] initWithXML:itemTemplateControlNode];
    self.controlDesc = itemTemplateControlDesc;
    [itemTemplateControlDesc release];

    // detail screen id
    self.detailScreenId = [self findDetailScreenId:controlDesc];

    return self;
}

- (NSString *)findDetailScreenId:(AGControlDesc *)controlDesc_ {
    NSString *result = nil;

    if (controlDesc_.onClickAction) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:controlDesc_.onClickAction.text];

        if ([scanner scanString:@"[d]goToScreenWithContext(" intoString:nil]) {
            [scanner scanString:@"'" intoString:nil];
            [scanner scanUpToString:@"'" intoString:&result];
            if (result.length == 0) {
                result = nil;
            }
        }

        [scanner release];
    }

    if ([controlDesc_ isKindOfClass:[AGContainerDesc class]]) {
        AGContainerDesc *containerDesc = (AGContainerDesc *)controlDesc_;
        for (AGControlDesc *child in containerDesc.children) {
            if (!result) result = [self findDetailScreenId:child];
        }
    }

    return result;
}

@end
