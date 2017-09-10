#import "AGFeedXMLParser.h"
#import "GDataXMLNode+XPath.h"
#import "AGApplication.h"
#import "NSString+HTML.h"
#import "AGLocalizationManager.h"

@implementation AGFeedXMLParser

- (AGDSFeed *)parseFeed:(AGFeed *)feed withData:(NSData *)data error:(NSError * *)error {
    AGDSFeed *feedDataSource = [[[AGDSFeed alloc] init] autorelease];

    // parse xml
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:data options:0 error:error];
    if (*error) {
        NSLog(@"Error occur while parsing XML document: %@", [*error description]);
        [xmlDocument release];

        // toast
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"ERROR_DATA"] ];
        }];

        return feedDataSource;
    }

    // pagination
    if (feed.paginationType != feedPaginantionNone) {
        feedDataSource.pagination = [xmlDocument.rootElement stringValueForXPath:feed.paginationPath namespaces:feed.namespaces];
    }

    // items
    NSArray *itemsNodes = [xmlDocument.rootElement nodesForXPath:feed.itemPath namespaces:feed.namespaces error:nil];

    // items
    for (GDataXMLNode *itemNode in itemsNodes) {
        // all using fields
        NSMutableDictionary *usingFieldsValues = [NSMutableDictionary dictionary];
        [feed.usingFields enumerateKeysAndObjectsUsingBlock:^(NSString *fieldId, NSString *xPath, BOOL *stop) {
            NSArray *nodes = [itemNode nodesForXPath:xPath namespaces:feed.namespaces error:nil];
            if (nodes.count) {
                NSString *value = [nodes[0] stringValue];
                usingFieldsValues[fieldId] = value;
            }
        }];

        // item template index
        NSInteger itemTemplateIndex = [self itemTemplateIndex:feed withUsingFieldsValues:usingFieldsValues];

        // item
        if (itemTemplateIndex != NSNotFound || feed.itemTemplates.count == 0) {
            AGDSFeedItem *feedItem = [[AGDSFeedItem alloc] init];
            feedItem.itemTemplateIndex = itemTemplateIndex;

            // alter api context
            NSDictionary *alterApiNamespaces = [NSDictionary dictionaryWithObject:@"http://kinetise.com" forKey:@"k"];
            NSArray *alterApiContextNodes = [itemNode nodesForXPath:@"@k:context" namespaces:alterApiNamespaces error:nil];
            if (alterApiContextNodes.count) {
                feedItem.alterApiContext = [alterApiContextNodes[0] stringValue];
            }

            // using fields
            [usingFieldsValues enumerateKeysAndObjectsUsingBlock:^(NSString *fieldId, NSString *value, BOOL *stop){
                feedItem.values[fieldId] = value;
            }];

            // guid
            if (feed.guidUsingField) {
                feedItem.guid = feedItem.values[feed.guidUsingField];
            }

            // add item
            [feedDataSource.items addObject:feedItem];
            [feedItem release];

            // if no load more, parse only showItems
            if (!feed.itemTemplateLoadMore && feedDataSource.items.count >= feed.showItems && feed.showItems > 0) {
                break;
            }
        }
    }

    [xmlDocument release];

    // sort
    //[self sortFeed:feed withDatasource:feedDataSource];

    return feedDataSource;
}

@end
