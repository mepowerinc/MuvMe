#import "AGGPSTracker.h"
#import "AGServicesManager.h"
#import "AGApplication.h"
#import "AGDataProvider.h"
#import "AGReachability.h"
#import "NSURLRequest+HTTP.h"
#import "NSString+GUID.h"

@interface AGGPSTracker () <CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>{
    BOOL isTracking;
}
@property(nonatomic, copy) NSNumber *trackId;
@property(nonatomic, retain) NSURLSession *session;
@property(nonatomic, retain) NSURLSessionDataTask *sessionTask;
@property(nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation AGGPSTracker

SINGLETON_IMPLEMENTATION(AGGPSTracker)

#pragma mark - Initialization

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.trackId = nil;
    self.trackingURL = nil;
    self.trackingHttpQuery = nil;
    self.trackingHttpHeaders = nil;
    self.session = nil;
    self.sessionTask = nil;
    self.locationManager = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    // session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 1;
    
    // session
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    // notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // send locations
    [self scheduleSendLocations:0];
    
    return self;
}

#pragma mark - Lifecycle

- (void)startTracking:(CGFloat)distanceFilter {
    if (isTracking) return;
    
    isTracking = YES;
    
    // clean empty tracks
    [DATABASE executeUpdate:@"DELETE FROM GpsTrack WHERE TrackId NOT IN (SELECT DISTINCT TrackId FROM GpsTrackLocation)"];
    
    // store track
    [DATABASE executeUpdate:@"INSERT INTO GpsTrack (Url, Query, Header) VALUES (?, ?, ?)",
     _trackingURL.absoluteString,
     [NSJSONSerialization dataWithJSONObject:_trackingHttpQuery options:0 error:nil],
     [NSJSONSerialization dataWithJSONObject:_trackingHttpHeaders options:0 error:nil]
     ];
    
    // set track id
    self.trackId = @(DATABASE.lastInsertRowId);
    
    // location manager
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = distanceFilter;
    
    // authorization
    [_locationManager requestAlwaysAuthorization];
}

- (void)stopTracking {
    if (!isTracking) return;
    
    isTracking = NO;
    [_locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    // clean empty tracks
    [DATABASE executeUpdate:@"DELETE FROM GpsTrack WHERE TrackId NOT IN (SELECT DISTINCT TrackId FROM GpsTrackLocation)"];
}

- (void)storeLocation:(CLLocation *)location {
    [DATABASE executeUpdate:@"INSERT INTO GpsTrackLocation (TrackId, Longitude, Latitude, Altitude, Accuracy, Timestamp) VALUES (?, ?, ?, ?, ?, ?)",
     _trackId,
     @(location.coordinate.longitude),
     @(location.coordinate.latitude),
     @(location.altitude),
     @(MAX(location.verticalAccuracy, location.horizontalAccuracy) ),
     @([[NSDate date] timeIntervalSince1970])
     ];
}

- (void)scheduleSendLocations:(CGFloat)delay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(sendLocations) withObject:nil afterDelay:delay inModes:@[NSRunLoopCommonModes] ];
}

- (void)sendLocations {
    if (_sessionTask || [AGReachability sharedInstance].reachability.currentReachabilityStatus == NotReachable) return;
    
    NSNumber *trackId = nil;
    NSURL *url = nil;
    NSDictionary *httpQuery = nil;
    NSDictionary *httpHeadr = nil;
    NSMutableArray *locations = [NSMutableArray array];
    
    // locations
    FMResultSet *s = [DATABASE executeQuery:@"SELECT * FROM GpsTrackLocation ORDER BY LocationId ASC LIMIT 100"];
    while ([s next]) {
        if (!trackId) {
            trackId = @([s intForColumn:@"TrackId"]);
        } else {
            if (![trackId isEqual:@([s intForColumn:@"TrackId"])]) {
                break;
            }
        }
        
        [locations addObject:@{
                               @"location_id": @([s intForColumn:@"LocationId"]),
                               @"longitude": @([s doubleForColumn:@"Longitude"]),
                               @"latitude": @([s doubleForColumn:@"Latitude"]),
                               @"altitude": @([s doubleForColumn:@"Altitude"]),
                               @"accuracy": @([s doubleForColumn:@"Accuracy"]),
                               @"timestamp": @((int64_t)([s doubleForColumn:@"Timestamp"]*1000)).stringValue
                               }];
    }
    [s close];
    
    if (!trackId) {
        return;
    }
    
    // track
    s = [DATABASE executeQuery:@"SELECT * FROM GpsTrack WHERE TrackId=?", trackId];
    if ([s next]) {
        url = [NSURL URLWithString:[s stringForColumn:@"Url"] ];
        httpQuery = [NSJSONSerialization JSONObjectWithData:[s dataForColumn:@"Query"] options:0 error:nil];
        httpHeadr = [NSJSONSerialization JSONObjectWithData:[s dataForColumn:@"Header"] options:0 error:nil];
    }
    [s close];
    
    
    // request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = AG_TIME_OUT;
    
    // http query params
    [request setGETParameters:httpQuery];
    
    // http header params
    [request addHTTPHeaders:httpHeadr];
    
    // user agent
    [request addValue:AGAPPLICATION.descriptor.defaultUserAgent forHTTPHeaderField:@"User-Agent"];
    
    // kinetise headers
    [[AGServicesManager sharedInstance].kinetiseHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    
    // body
    NSMutableArray *bodyJSON = [NSMutableArray array];
    for (NSDictionary *location in locations) {
        [bodyJSON addObject:@{
                              @"form": @{},
                              @"params": @{
                                      @"longitude": location[@"longitude"],
                                      @"latitude": location[@"latitude"],
                                      @"altitude": location[@"altitude"],
                                      @"accuracy": location[@"accuracy"],
                                      @"timestamp": location[@"timestamp"]
                                      }
                              }];
    }
    
    // http body
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyJSON options:0 error:nil];
    
    // content-type
    if (!request.allHTTPHeaderFields[@"Content-Type"] && !request.allHTTPHeaderFields[@"content-type"]) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    // log
    //[AGAPPLICATION.toast makeToast: [NSString stringWithFormat:@"GPS request: %d", locations.count] withDuration:1 andPriority:toastPriorityNormal usingColor:[UIColor redColor]];
    
    // session task
    __block AGGPSTracker *weakSelf = self;
    self.sessionTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            CGFloat delay = 0;
            
            // log
            //[AGAPPLICATION.toast makeToast:[NSString stringWithFormat:@"GPS response: %d", httpResponse.statusCode] withDuration:1 andPriority:toastPriorityNormal usingColor:[UIColor redColor]];
            
            // remove sended locations
            if (httpResponse.statusCode == 200) {
                for (NSDictionary *location in locations) {
                    [DATABASE executeUpdate:@"DELETE FROM GpsTrackLocation WHERE LocationId=?", location[@"location_id"] ];
                }
            } else {
                delay = 10;
            }
            
            // schedule send locations
            weakSelf.sessionTask = nil;
            [weakSelf scheduleSendLocations:delay];
        });
    }];
    
    // start session task
    [_sessionTask resume];
}

- (void)synchronizeLocation:(CLLocation *)location {
    // store location
    [self storeLocation:location];
    
    // schedule send locations
    [self scheduleSendLocations:0];
}

- (void)synchronizeLocationImmediatly:(CLLocation *)location {
    // store location
    [self storeLocation:location];
    
    // synchronize
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self sendLocations];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = locations.lastObject;
    
    // log
    //[AGAPPLICATION.toast makeToast: [NSString stringWithFormat:@"GPS update: %f, %f", location.coordinate.latitude, location.coordinate.longitude] withDuration:1 andPriority:toastPriorityNormal usingColor:[UIColor redColor]];
    
    // synchronize location
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        __block UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid;
        
        // start background task
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
                  ^{
                      [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                      bgTask = UIBackgroundTaskInvalid;
                  }];
        
        // synchronize in background
        [self synchronizeLocationImmediatly:location];
        
        // end background task
        if (bgTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }
    } else {
        [self synchronizeLocation:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch (error.code) {
        case kCLErrorLocationUnknown:
            break;
        case kCLErrorDenied:
            [manager stopUpdatingLocation];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (isTracking && status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted) {
        // alow background location
        NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"location"]) {
            if ([manager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
                [manager setAllowsBackgroundLocationUpdates:YES];
            }
        }
        
        // start updating location
        [manager startUpdatingLocation];
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    completionHandler(request);
}

#pragma mark - Notifications

- (void)changeNetworkStatus:(NSNotification *)notification {
    Reachability *reachability = notification.object;
    NetworkStatus networkStatus = reachability.currentReachabilityStatus;
    
    // schedule send locations
    if (networkStatus != NotReachable) {
        [self scheduleSendLocations:0];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self scheduleSendLocations:0];
}

@end
