#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSCustom <JSExport>
- (void)action;
@end

@interface AGJSCustom : NSObject <AGJSCustom>

@end
