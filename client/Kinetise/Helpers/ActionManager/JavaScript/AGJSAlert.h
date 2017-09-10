#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSAlertExport <JSExport>
- (void)alert:(NSString *)title :(NSString *)message :(NSString *)closeTitle :(JSValue *)closeCallback :(NSString *)actionTitle :(JSValue *)actionCallback;
@end

@interface AGJSAlert : NSObject <AGJSAlertExport>
@end
