#import "AGActionManager+Actions.h"
#import "AGApplication.h"
#import "AGGPSLocator.h"
#import "AGGPSTracker.h"
#import "AGSocialManager.h"
#import "AGLocalizationManager.h"
#import "UIDevice+Hardware.h"
#import "NSString+GUID.h"

@implementation AGActionManager (Actions)

- (NSString *)getAppName:(id)sender :(id)object {
    return AGAPPLICATION.descriptor.name;
}

- (NSString *)getScreenName:(id)sender :(id)object {
    return AGAPPLICATION.currentScreenDesc.atag;
}

- (NSString *)getAlterApiContext:(id)sender :(id)object {
    return AGAPPLICATION.alterApiContext ? AGAPPLICATION.alterApiContext : @"";
}

- (NSString *)getGpsAccuracy:(id)sender :(id)object {
    return [AGGPSLocator sharedInstance].hasGPSLocation ? [NSString stringWithFormat:@"%f", [AGGPSLocator sharedInstance].accuracy] : @"";
}

- (NSString *)getGpsLongitude:(id)sender :(id)object {
    return [AGGPSLocator sharedInstance].hasGPSLocation ? [NSString stringWithFormat:@"%f", [AGGPSLocator sharedInstance].longitude] : @"";
}

- (NSString *)getGpsLatitude:(id)sender :(id)object {
    return [AGGPSLocator sharedInstance].hasGPSLocation ? [NSString stringWithFormat:@"%f", [AGGPSLocator sharedInstance].latitude] : @"";
}

- (NSString *)getGpsAltitude:(id)sender :(id)object {
    return [AGGPSLocator sharedInstance].hasGPSLocation ? [NSString stringWithFormat:@"%f", [AGGPSLocator sharedInstance].altitude] : @"";
}

- (BOOL)isDouble:(NSString *)string {
    if (string.doubleValue != 0) {
        return YES;
    } else if ([string isEqualToString:@"0"]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)calculateGeoDistance:(id)sender :(id)object :(NSString *)latitude1 :(NSString *)longitude1 :(NSString *)latitude2 :(NSString *)longitude2 :(NSString *)unit {
    if (![self isDouble:latitude1] || ![self isDouble:longitude1] || ![self isDouble:latitude2] || ![self isDouble:longitude2]) {
        return @"N/A";
    }
    
    if (!CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(latitude1.doubleValue, longitude1.doubleValue)) ) {
        return @"N/A";
    }
    
    if (!CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(latitude2.doubleValue, longitude2.doubleValue)) ) {
        return @"N/A";
    }
    
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:latitude1.doubleValue longitude:longitude1.doubleValue];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:latitude2.doubleValue longitude:longitude2.doubleValue];
    
    CLLocationDistance distance = [location1 distanceFromLocation:location2];
    [location1 release];
    [location2 release];
    
    CLLocationDistance convertedDistance = distance;
    
    if ([unit isEqualToString:@"KM"]) {
        convertedDistance = distance * 0.001;
    } else if ([unit isEqualToString:@"MI"]) {
        convertedDistance = distance * 0.000621371192;
    } else if ([unit isEqualToString:@"NMI"]) {
        convertedDistance = distance * 0.000539956803;
    }
    
    return [NSString stringWithFormat:@"%.2f", convertedDistance];
}

- (NSString *)getDeviceToken:(id)sender :(id)object {
    return [[UIDevice currentDevice] deviceUuid];
}

- (NSString *)getFbAccessToken:(id)sender :(id)object {
    return AGSOCIALMANAGER.facebookAccessToken ? AGSOCIALMANAGER.facebookAccessToken : @"";
}

- (NSString *)getTwitterAccessToken:(id)sender :(id)object {
    return AGSOCIALMANAGER.twitterAccessToken ? AGSOCIALMANAGER.twitterAccessToken : @"";
}

- (NSString *)getHeaderParamValue:(id)sender :(id<AGFeedClientProtocol>)object :(NSString *)paramName {
    if ([object conformsToProtocol:@protocol(AGFeedClientProtocol)]) {
        if ([object feed].httpHeaderParams.params[paramName]) {
            return [AGACTIONMANAGER executeString:[object feed].httpHeaderParams.params[paramName] withSender:sender];
        }
    }
    
    return @"";
}

- (NSString *)getCurrentTime:(id)sender :(id)object {
    return [dateFormatterRFC3339 stringFromDate:[NSDate date] ];
}

- (NSString *)getPageSize:(id)sender :(AGControlDesc<AGFeedClientProtocol> *)object {
    return [NSString stringWithFormat:@"%zd", object.feed.showItems];
}

- (NSString *)generateGuid:(id)sender :(id)object {
    return [NSString stringWithGUID];
}

- (void)delay:(id)sender :(id)object :(NSString *)action :(NSString *)timeout {
    [AGAPPLICATION.currentScreen delayAction:action withTimeout:[timeout integerValue] ];
}

- (void)startGPSTracking:(id)sender :(id)object :(NSString *)uri :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)interval :(NSString *)distance {
    // uri
    uri = [[sender fullPath:uri] uriString];
    
    // params
    AGHTTPQueryParams *httpQueryParams = [AGHTTPQueryParams paramsWithJSONString:httpQueryParamsString ];
    AGHTTPHeaderParams *httpHeaderParams = [AGHTTPHeaderParams paramsWithJSONString:headerParamsString ];
    
    // tracker settings
    [[AGGPSTracker sharedInstance] stopTracking];
    [AGGPSTracker sharedInstance].trackingURL = [NSURL URLWithString:uri];
    [AGGPSTracker sharedInstance].trackingHttpQuery = [httpQueryParams execute:sender];
    [AGGPSTracker sharedInstance].trackingHttpHeaders = [httpHeaderParams execute:sender];
    [[AGGPSTracker sharedInstance] startTracking:[distance doubleValue] ];
}

- (void)endGPSTracking:(id)sender :(id)object {
    [[AGGPSTracker sharedInstance] stopTracking];
}

@end
