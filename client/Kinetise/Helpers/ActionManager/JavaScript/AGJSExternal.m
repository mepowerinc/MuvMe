#import "AGJSExternal.h"
#import "AGActionManager.h"
#import "AGActionManager+External.h"
#import "NSDate+RFC3339.h"

@implementation AGJSExternal

- (void)video:(NSDictionary *)request {
    [AGACTIONMANAGER showInVideoPlayer:nil :nil :request[@"url"]];
}

- (void)web:(NSDictionary *)request {
    if (request[@"params"]) {
        [AGACTIONMANAGER showInWebBrowser:nil :nil :request[@"url"] :[AGACTIONMANAGER paramsJsonString:request[@"params"]]];
    } else {
        [AGACTIONMANAGER showInWebBrowser:nil :nil :request[@"url"]];
    }
}

- (void)email:(NSString *)subject :(NSString *)body :(NSArray *)recipients {
    [[AGActionManager sharedInstance] openEmail:nil :nil :subject :body :recipients.firstObject];
}

- (void)sms:(NSString *)phoneNumber :(NSString *)message {
    [AGACTIONMANAGER openSMS:nil :nil :phoneNumber :message];
}

- (void)file:(NSDictionary *)request {
    [AGACTIONMANAGER openFile:nil :nil :request[@"url"]];
}

- (void)map:(NSString *)type :(NSNumber *)endLatitude :(NSNumber *)endLongitude :(NSString *)endName {
    [AGACTIONMANAGER openMapCurrentLocation:nil :nil :[endLatitude stringValue] :[endLongitude stringValue] :endName :type];
}

- (void)map:(NSString *)type :(NSNumber *)endLatitude :(NSNumber *)endLongitude :(NSString *)endName :(NSNumber *)startLatitude :(NSNumber *)startLongitude :(NSString *)startName {
    [AGACTIONMANAGER openMap:nil :nil :[startLatitude stringValue] :[startLongitude stringValue] :[endLatitude stringValue] :[endLongitude stringValue] :startName :endName :type];
}

- (void)calendar:(NSString *)title :(NSString *)note :(NSString *)location :(NSDate *)start :(NSDate *)end :(NSNumber *)allDay {
    NSDateFormatter *dateFormatter = [NSDateFormatter RFC3339dateFormatter];
    
    [AGACTIONMANAGER addCalendarEvent:nil :nil :title :note :location :[dateFormatter stringFromDate:start] :[dateFormatter stringFromDate:end] :[allDay stringValue]];
}

- (void)call:(NSString *)phoneNumber {
    [AGACTIONMANAGER call:nil :nil :phoneNumber];
}

- (void)payment:(NSDictionary *)request :(JSValue *)successCallback :(JSValue *)failureCallback {
    [AGACTIONMANAGER payment:nil :nil :request[@"url"] :nil :nil :[AGACTIONMANAGER paramsJsonString:request[@"params"]]];
}

- (void)offline:(NSArray *)content {
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:content options:0 error:nil] encoding:NSUTF8StringEncoding];
    [AGACTIONMANAGER offlineReading:nil :nil :jsonString];
    [jsonString release];
}

- (void)share:(NSArray *)content {
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:content options:0 error:nil] encoding:NSUTF8StringEncoding];
    [AGACTIONMANAGER nativeShare:nil :nil :jsonString];
    [jsonString release];
}

- (void)qr {
    [AGACTIONMANAGER scanQRCode:nil :nil];
}

@end
