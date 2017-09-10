#import "AGFeedParser.h"
#import "NSObject+Nil.h"
#import "AGApplication.h"
#import "AGRegexExtractor.h"

@implementation AGFeedParser

- (AGDSFeed *)parseFeed:(AGFeed *)feed withData:(NSData *)data error:(NSError * *)error {
    return nil;
}

- (NSInteger)itemTemplateIndex:(AGFeed *)feed withUsingFieldsValues:(NSDictionary *)usingFieldsValues {
    for (int i = 0; i < feed.itemTemplates.count; ++i) {
        AGFeedItemTemplate *itemTemplate = feed.itemTemplates[i];

        if (itemTemplate.requiredFields.count == 0) {
            return i;
        } else {
            NSInteger numOfMatch = 0;
            for (AGFeedRequiredField *requiredField in itemTemplate.requiredFields) {
                if ([self hasMatch:usingFieldsValues withRequiredField:requiredField]) {
                    ++numOfMatch;
                }
            }
            if (numOfMatch == itemTemplate.requiredFields.count) {
                return i;
            }
        }
    }

    return NSNotFound;
}

- (BOOL)hasMatch:(NSDictionary *)usingFieldsValues withRequiredField:(AGFeedRequiredField *)requiredField {
    NSString *value = usingFieldsValues[requiredField.field];

    if (!value) {
        return NO;
    }

    // regex
    if (isNotEmpty(requiredField.regexName) ) {
        value = [AGRegexExtractor processTagsWithString:value andRegexName:requiredField.regexName];
    }

    // match
    if (!([requiredField.match isKindOfClass:[NSString class]] && [requiredField.match length] == 0) ) {
        if (![value isEqual:requiredField.match]) {
            return NO;
        }
    }

    // allow empty
    if (!requiredField.allowEmpty) {
        if (value == nil || [value isEqual:[NSNull null]] || ([value isKindOfClass:[NSString class]] && [value length] == 0) ) {
            return NO;
        }
    }

    return YES;
}

- (void)sortFeed:(AGFeed *)feed withDatasource:(AGDSFeed *)ds {
    if (isEmpty(feed.sortField) ) return;

    [ds.items sortUsingComparator:^NSComparisonResult (AGDSFeedItem *item1, AGDSFeedItem *item2) {
        NSString *value1 = item1.values[feed.sortField];
        NSString *value2 = item2.values[feed.sortField];

        if (isEmpty(value1) ) return NSOrderedDescending;
        if (isEmpty(value2) ) return NSOrderedAscending;

        if (feed.sortOrder == feedSortOrderAscending) {
            return [value1 caseInsensitiveCompare:value2];
        } else if (feed.sortOrder == feedSortOrderDescending) {
            return -[value1 caseInsensitiveCompare:value2];
        }

        return NSOrderedSame;
    }];
}

@end
