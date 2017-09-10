#import "AGOfflineReaderFeedJSONOperation.h"
#import "NSDictionary+JSONPath.h"
#import "NSArray+JSONPath.h"
#import "NSString+HTML.h"

@implementation AGOfflineReaderFeedJSONOperation

- (void)parseFeed:(NSData *)data {
    id json_ = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
    if (!json_) {
        [self onFail:nil];
        return;
    }

    if (self.isCancelled) return;

    // children
    NSMutableArray *result = [NSMutableArray array];
    NSArray *children = json[@"nodes"];
    NSString *itemPath = json[@"itemPath"];
    NSDictionary *usingFields = json[@"usingFields"];

    for (NSMutableDictionary *child in children) {
        NSString *usingField = child[@"usingFieldInParent"];
        NSString *jsonPath = usingFields[usingField];

        NSArray *items = [json_ nodesForJSONPath:itemPath];
        for (id item in items) {
            NSArray *nodes = [item nodesForJSONPath:jsonPath];
            if (nodes.count) {
                NSString *uri = nodes[0];

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
