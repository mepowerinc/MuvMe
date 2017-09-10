#import "AGDSFeedItem.h"

@interface AGDSFeed : NSObject {
    NSMutableArray *items;
    NSInteger itemIndex;
    NSString *pagination;
}

@property(nonatomic, retain) NSMutableArray *items;
@property(nonatomic, assign) NSInteger itemIndex;
@property(nonatomic, copy) NSString *pagination;

@end
