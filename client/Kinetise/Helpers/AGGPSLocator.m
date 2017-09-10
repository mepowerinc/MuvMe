#import "AGGPSLocator.h"
#import "AGApplication.h"

NSString *const AGGPSLocationAvailableNotification = @"AGGPSLocationAvailableNotification";
NSString *const AGGPSLocationChangeNotification = @"AGGPSLocationChangeNotification";

@interface AGGPSLocator () <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    double latitude;
    double longitude;
    double altitude;
    double accuracy;
}
@property(nonatomic, assign) BOOL hasGPSLocation;
@property(nonatomic, copy) void (^authorizationBlock)(CLAuthorizationStatus authorizationStatus);
@end

@implementation AGGPSLocator

@synthesize latitude;
@synthesize longitude;
@synthesize altitude;
@synthesize accuracy;
@synthesize hasGPSLocation;
@synthesize authorizationBlock;

SINGLETON_IMPLEMENTATION(AGGPSLocator);

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [locationManager release];
    self.authorizationBlock = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // settings
    latitude = 0;
    longitude = 0;
    altitude = 0;
    accuracy = 0;

    // location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;

    // authorization
    if (AGAPPLICATION.descriptor.permissions&AGPermissionGPSTracking) {
        [locationManager requestAlwaysAuthorization];
    } else {
        [locationManager requestWhenInUseAuthorization];
    }

    // notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicatioDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    return self;
}

#pragma mark - Lifecycle

- (CLLocationCoordinate2D)location {
    return CLLocationCoordinate2DMake(latitude, longitude);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];

    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    altitude = location.altitude;
    accuracy = MAX(location.verticalAccuracy, location.horizontalAccuracy);

    if (!hasGPSLocation) {
        hasGPSLocation = YES;

        // post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:AGGPSLocationAvailableNotification object:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch (error.code) {
    case kCLErrorLocationUnknown:
        break;
    case kCLErrorDenied:
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager stopUpdatingLocation];
        break;
    default:
        break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted) {
        if (self.authorizationBlock) {
            self.authorizationBlock(status);
            self.authorizationBlock = nil;
        }

        [locationManager startUpdatingLocation];
    }
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
}

- (void)applicatioDidEnterBackground:(NSNotification *)notification {
    [locationManager stopUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];
}

@end
