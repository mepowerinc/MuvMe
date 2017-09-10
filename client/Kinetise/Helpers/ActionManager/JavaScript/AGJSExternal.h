#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSExternalExport <JSExport>
- (void)video:(NSDictionary *)request;
- (void)web:(NSDictionary *)request;
- (void)email:(NSString *)subject :(NSString *)body :(NSArray *)recipients;
- (void)sms:(NSString *)phoneNumber :(NSString *)message;
- (void)file:(NSDictionary *)request;
- (void)map:(NSString *)type :(NSNumber *)endLatitude :(NSNumber *)endLongitude :(NSString *)endName;
- (void)map:(NSString *)type :(NSNumber *)endLatitude :(NSNumber *)endLongitude :(NSString *)endName :(NSNumber *)startLatitude :(NSNumber *)startLongitude :(NSString *)startName;
- (void)calendar:(NSString *)title :(NSString *)note :(NSString *)location :(NSDate *)start :(NSDate *)end :(NSNumber *)allDay;
- (void)call:(NSString *)phoneNumber;
- (void)payment:(NSDictionary *)request :(JSValue *)successCallback :(JSValue *)failureCallback;
- (void)offline:(NSArray *)content;
- (void)share:(NSArray *)content;
- (void)qr;
@end

@interface AGJSExternal : NSObject <AGJSExternalExport>
@end
