#import "AGControlDesc.h"
#import "AGFeedClientProtocol.h"

@interface AGMapDesc : AGControlDesc <AGFeedClientProtocol>{
    AGControlDesc *indicatorDesc;
    AGFeed *feed;
    AGSize pinSize;
    AGVariable *geoDataSrc;
    AGVariable *xSrc;
    AGVariable *ySrc;
    AGVariable *pinSrc;
    AGMapRegion region;
    CGFloat regionRadius;
    BOOL showUserLocation;
    BOOL showMapPopup;
}

@property(nonatomic, readonly) AGControlDesc *indicatorDesc;
@property(nonatomic, assign) AGSize pinSize;
@property(nonatomic, retain) AGVariable *geoDataSrc;
@property(nonatomic, retain) AGVariable *xSrc;
@property(nonatomic, retain) AGVariable *ySrc;
@property(nonatomic, retain) AGVariable *pinSrc;
@property(nonatomic, assign) AGMapRegion region;
@property(nonatomic, assign) CGFloat regionRadius;
@property(nonatomic, assign) BOOL showUserLocation;
@property(nonatomic, assign) BOOL showMapPopup;

@end
