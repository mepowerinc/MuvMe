#import "AGFeedDBParser.h"
#import "AGApplication.h"
#import "AGLocalizationManager.h"

@implementation AGFeedDBParser

- (AGDSFeed *)parseFeed:(AGFeed *)feed withData:(NSData *)data error:(NSError * *)error {
    AGDSFeed *feedDataSource = [[[AGDSFeed alloc] init] autorelease];

    // items
    NSArray *itemsNodes = (NSArray *)data;

    // items
    for (NSDictionary *itemNode in itemsNodes) {
        // all using fields
        NSMutableDictionary *usingFieldsValues = [NSMutableDictionary dictionary];
        [feed.usingFields enumerateKeysAndObjectsUsingBlock:^(NSString *fieldId, NSString *keyPath, BOOL *stop) {
            id value = [itemNode valueForKeyPath:keyPath];
            if (value) {
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
    }

    return nil;
}

@end
