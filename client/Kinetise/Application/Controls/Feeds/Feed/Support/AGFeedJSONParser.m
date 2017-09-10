#import "AGFeedJSONParser.h"
#import "AGLocalizationManager.h"
#import "AGApplication.h"
#import "NSArray+JSONPath.h"
#import "NSDictionary+JSONPath.h"
#import "NSString+HTML.h"
#import "NSObject+Nil.h"

@implementation AGFeedJSONParser

- (AGDSFeed *)parseFeed:(AGFeed *)feed withData:(NSData *)data error:(NSError * *)error {
    AGDSFeed *feedDataSource = [[[AGDSFeed alloc] init] autorelease];
    
    // parse json
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (*error) {
        NSLog(@"Error occur while parsing JSON document: %@", [*error description]);
        
        // toast
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"ERROR_DATA"] ];
        }];
        
        return feedDataSource;
    }
    
    // pagination
    if (feed.paginationType != feedPaginantionNone) {
        NSArray *nodes = [json nodesForJSONPath:feed.paginationPath];
        if (nodes.count) {
            NSString *stringValue = [self jsonStringValue:nodes[0] ];
            
            if (stringValue) {
                feedDataSource.pagination = stringValue;
            }
        }
    }
    
    // items
    NSArray *itemsNodes = [json nodesForJSONPath:feed.itemPath];
    
    // items
    for (NSDictionary *itemNode in itemsNodes) {
        // all using fields
        NSMutableDictionary *usingFieldsValues = [NSMutableDictionary dictionary];
        [feed.usingFields enumerateKeysAndObjectsUsingBlock:^(NSString *fieldId, NSString *jsonPath, BOOL *stop) {
            NSArray *nodes = [itemNode nodesForJSONPath:jsonPath];
            if (nodes.count) {
                id value = nodes[0];
                usingFieldsValues[fieldId] = value;
            }
        }];
        
        // item template index
        NSInteger itemTemplateIndex = [self itemTemplateIndex:feed withUsingFieldsValues:usingFieldsValues];
        
        // item
        if (itemTemplateIndex != NSNotFound || feed.itemTemplates.count == 0) {
            AGDSFeedItem *feedItem = [[AGDSFeedItem alloc] init];
            feedItem.itemTemplateIndex = itemTemplateIndex;
            
            // using fields
            [usingFieldsValues enumerateKeysAndObjectsUsingBlock:^(NSString *fieldId, id value, BOOL *stop) {
                NSString *stringValue = [self jsonStringValue:value];
                
                if (stringValue) {
                    feedItem.values[fieldId] = stringValue;
                }
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
    
    // sort
    //[self sortFeed:feed withDatasource:feedDataSource];
    
    return feedDataSource;
}

- (NSString *)jsonStringValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if (value == (void *)kCFBooleanFalse || value == (void *)kCFBooleanTrue) {
            if ([value boolValue]) {
                return @"true";
            } else {
                return @"false";
            }
        } else {
            return [value stringValue];
        }
    } else if ([value isKindOfClass:[NSNull class]]) {
        return @"";
    } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
        return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    }
    
    return nil;
}

@end
