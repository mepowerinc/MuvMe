#import "AGFeed+XML.h"
#import "AGParser.h"
#import "AGFeedItemTemplate+XML.h"

@implementation AGFeed (XML)

- (id)initWithXML:(GDataXMLNode *)node {
    self = [self init];

    // namespaces
    if ([node hasNodeForXPath:@"namespaces"]) {
        NSArray *namespaceNodes = [node nodesForXPath:@"namespaces/namespace"];
        for (GDataXMLNode *namespaceNode in namespaceNodes) {
            [namespaces setObject:[namespaceNode stringValue] forKey:[namespaceNode stringValueForXPath:@"@prefix"]];
        }
    }

    // using fields
    NSArray *usingFieldNodes = [node nodesForXPath:@"usingfields/field"];
    for (GDataXMLNode *usingFieldNode in usingFieldNodes) {
        [usingFields setObject:[usingFieldNode stringValue] forKey:[usingFieldNode stringValueForXPath:@"@id"]];
    }

    // sorting
    if ([node hasNodeForXPath:@"sorting"]) {
        self.sortField = [node stringValueForXPath:@"sorting/field"];
        self.sortOrder = AGFeedSortOrderWithText([node stringValueForXPath:@"sorting/order"]);
    } else {
        self.sortField = @"";
        sortOrder = feedSortOrderAscending;
    }

    // http query params
    self.httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:[node stringValueForXPath:@"@httpparams"] ];

    // http header params
    self.httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:[node stringValueForXPath:@"@headerparams"] ];

    // http body params
    self.httpBodyParams = [AGHTTPBodyParams paramsWithJSONString:[node stringValueForXPath:@"@bodyparams"] ];

    // request body transform
    self.requestBodyTransform = [node stringValueForXPath:@"@requestbodytransform"];

    // http method
    self.httpMethod = [[node stringValueForXPath:@"@httpmethod"] uppercaseString];

    // cache policy
    self.cachePolicy = AGCachePolicyWithText([node stringValueForXPath:@"@cachepolicy"]);

    // cache interval
    self.cacheInterval = (CGFloat)[node integerValueForXPath:@"@cachepolicyattribute"]/1000.0f;

    // format
    if ([[node stringValueForXPath:@"@format"] isEqualToString:@"XML"]) {
        format = feedFormatXML;
    } else if ([[node stringValueForXPath:@"@format"] isEqualToString:@"JSON"]) {
        format = feedFormatJSON;
    } else if ([[node stringValueForXPath:@"@format"] isEqualToString:@"CSV"]) {
        format = feedFormatCSV;
    } else if ([[node stringValueForXPath:@"@format"] isEqualToString:@"LOCAL"]) {
        format = feedFormatDB;
    }

    // local db params
    if (format == feedFormatDB && [node hasNodeForXPath:@"@localdbparams"]) {
        self.httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:[node stringValueForXPath:@"@localdbparams"] ];
    }

    // item path
    self.itemPath = [node stringValueForXPath:@"itempath"];

    // show items
    showItems = [node integerValueForXPath:@"@showitems"];

    // src
    self.src = [AGVariable variableWithText:[node stringValueForXPath:@"@urisource"] ];

    // item templates
    NSArray *itemTemplateNodes = [node nodesForXPath:@"itemtemplate"];
    for (int i = 0; i < itemTemplateNodes.count; ++i) {
        GDataXMLNode *itemTemplateNode = itemTemplateNodes[i];
        AGFeedItemTemplate *itemTemplateDesc = [[AGFeedItemTemplate alloc] initWithXML:itemTemplateNode];
        [itemTemplates addObject:itemTemplateDesc];
        [itemTemplateDesc release];
        itemTemplateDesc.controlDesc.reuseIdentifier = [NSString stringWithFormat:@"%@_%zd", AG_REUSE_IDENTIFIER_ITEM_TEMPLATE, i];
    }

    // item template loading
    if ([node hasNodeForXPath:@"itemtemplateloading"]) {
        GDataXMLNode *controlNode = [node nodeForXPath:@"itemtemplateloading"].children[0];
        Class controlClass = [AGParser classWithName:controlNode.name];
        if (controlClass) {
            AGControlDesc *controlDesc = [[controlClass alloc] initWithXML:controlNode];
            self.itemTemplateLoading = controlDesc;
            controlDesc.reuseIdentifier = AG_REUSE_IDENTIFIER_LOADING;
            [controlDesc release];
        }
    }

    // item template no data
    if ([node hasNodeForXPath:@"itemtemplatenodata"]) {
        GDataXMLNode *controlNode = [node nodeForXPath:@"itemtemplatenodata"].children[0];
        Class controlClass = [AGParser classWithName:controlNode.name];
        if (controlClass) {
            AGControlDesc *controlDesc = [[controlClass alloc] initWithXML:controlNode];
            self.itemTemplateNoData = controlDesc;
            controlDesc.reuseIdentifier = AG_REUSE_IDENTIFIER_NO_DATA;
            [controlDesc release];
        }
    }

    // item template error
    if ([node hasNodeForXPath:@"itemtemplateerror"]) {
        GDataXMLNode *controlNode = [node nodeForXPath:@"itemtemplateerror"].children[0];
        Class controlClass = [AGParser classWithName:controlNode.name];
        if (controlClass) {
            AGControlDesc *controlDesc = [[controlClass alloc] initWithXML:controlNode];
            self.itemTemplateError = controlDesc;
            controlDesc.reuseIdentifier = AG_REUSE_IDENTIFIER_ERROR;
            [controlDesc release];
        }
    }

    // item template load more
    if ([node hasNodeForXPath:@"itemtemplateloadmore"]) {
        GDataXMLNode *controlNode = [node nodeForXPath:@"itemtemplateloadmore"].children[0];
        Class controlClass = [AGParser classWithName:controlNode.name];
        if (controlClass) {
            AGControlDesc *controlDesc = [[controlClass alloc] initWithXML:controlNode];
            self.itemTemplateLoadMore = controlDesc;
            controlDesc.reuseIdentifier = AG_REUSE_IDENTIFIER_LOAD_MORE;
            [controlDesc release];
        }
    }

    // csv separator
    if ([node hasNodeForXPath:@"@csvseparator"]) {
        self.csvSeparator = [node stringValueForXPath:@"@csvseparator"];
    } else {
        self.csvSeparator = @",";
    }

    // csv header
    if ([node hasNodeForXPath:@"@csvheader"]) {
        self.csvHeader = [node booleanValueForXPath:@"@csvheader"];
    } else {
        self.csvHeader = YES;
    }

    // guid using field
    if ([node hasNodeForXPath:@"@guid"]) {
        self.guidUsingField = [node stringValueForXPath:@"@guid"];
    }

    // form id
    if ([node hasNodeForXPath:@"@formid"]) {
        self.formId = [AGVariable variableWithText:[node stringValueForXPath:@"@formid"] ];
    }

    // pagination
    if ([node hasNodeForXPath:@"pagination/nextpageurl"]) {
        self.paginationType = feedPaginationURL;
        self.paginationPath = [node stringValueForXPath:@"pagination/nextpageurl"];
    } else if ([node hasNodeForXPath:@"pagination/nextpagetoken"]) {
        self.paginationType = feedPaginationToken;
        self.paginationPath = [node stringValueForXPath:@"pagination/nextpagetoken"];
        self.paginationHtthParam = [node stringValueForXPath:@"pagination/nextpagetoken/@param"];
    }

    return self;
}

@end
