#import "AGFeed.h"
#import "AGDSFeed.h"

@interface AGFeedParser : NSObject

- (AGDSFeed *)parseFeed:(AGFeed *)feed withData:(NSData *)data error:(NSError * *)error;
- (NSInteger)itemTemplateIndex:(AGFeed *)feed withUsingFieldsValues:(NSDictionary *)usingFieldsValues;
- (void)sortFeed:(AGFeed *)feed withDatasource:(AGDSFeed *)ds;

@end
