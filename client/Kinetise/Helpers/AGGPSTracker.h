#import <MapKit/MapKit.h>
#import "NSObject+Singleton.h"

@interface AGGPSTracker : NSObject

@property(nonatomic, retain) NSURL *trackingURL;
@property(nonatomic, retain) NSDictionary *trackingHttpQuery;
@property(nonatomic, retain) NSDictionary *trackingHttpHeaders;

SINGLETON_INTERFACE(AGGPSTracker)

- (void)startTracking:(CGFloat)distanceFilter;
- (void)stopTracking;

@end
