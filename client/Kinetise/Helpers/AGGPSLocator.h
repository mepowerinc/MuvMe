#import <MapKit/MapKit.h>
#import "NSObject+Singleton.h"

FOUNDATION_EXPORT NSString *const AGGPSLocationAvailableNotification;
FOUNDATION_EXPORT NSString *const AGGPSLocationChangeNotification;

@interface AGGPSLocator : NSObject

    SINGLETON_INTERFACE(AGGPSLocator)

@property(nonatomic, readonly) double latitude;
@property(nonatomic, readonly) double longitude;
@property(nonatomic, readonly) double altitude;
@property(nonatomic, readonly) double accuracy;
@property(nonatomic, readonly) BOOL hasGPSLocation;
@property(nonatomic, readonly) CLLocationCoordinate2D location;

@end
