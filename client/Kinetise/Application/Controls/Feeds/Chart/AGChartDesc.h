#import "AGControlDesc.h"
#import "AGFeedClientProtocol.h"

@interface AGChartDesc : AGControlDesc <AGFeedClientProtocol>{
    AGControlDesc *indicatorDesc;
    AGFeed *feed;
}

@property(nonatomic, readonly) AGControlDesc *indicatorDesc;
@property(nonatomic, assign) AGChartType type;
@property(nonatomic, copy) NSString *label;
@property(nonatomic, readonly) NSMutableArray *colors;
@property(nonatomic, readonly) NSMutableArray *dataset;

@end
