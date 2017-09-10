#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSFormExport <JSExport>
- (void)send:(NSDictionary *)request :(NSString *)controlId :(NSNumber *)async :(id)successCallback :(id)failureCallback;
@end

@interface AGJSForm : NSObject <AGJSFormExport>

@end
