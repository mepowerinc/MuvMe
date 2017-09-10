#import "AGActionManager.h"

@interface AGActionManager (Actions)

- (NSString *)getAppName:(id)sender :(id)object;
- (NSString *)getScreenName:(id)sender :(id)object;
- (NSString *)getAlterApiContext:(id)sender :(id)object;
- (NSString *)getGpsAccuracy:(id)sender :(id)object;
- (NSString *)getGpsLongitude:(id)sender :(id)object;
- (NSString *)getGpsLatitude:(id)sender :(id)object;
- (NSString *)getGpsAltitude:(id)sender :(id)object;
- (NSString *)calculateGeoDistance:(id)sender :(id)object :(NSString *)latitude1 :(NSString *)longitude1 :(NSString *)latitude2 :(NSString *)longitude2 :(NSString *)unit;
- (NSString *)getDeviceToken:(id)sender :(id)object;
- (NSString *)getFbAccessToken:(id)sender :(id)object;
- (NSString *)getTwitterAccessToken:(id)sender :(id)object;
- (NSString *)getHeaderParamValue:(id)sender :(id)object :(NSString *)paramName;
- (NSString *)getCurrentTime:(id)sender :(id)object;
- (NSString *)getPageSize:(id)sender :(id)object;
- (NSString *)generateGuid:(id)sender :(id)object;
- (void)delay:(id)sender :(id)object :(NSString *)action :(NSString *)timeout;
- (void)startGPSTracking:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)interval :(NSString *)distance;
- (void)endGPSTracking:(id)sender :(id)object;

@end
