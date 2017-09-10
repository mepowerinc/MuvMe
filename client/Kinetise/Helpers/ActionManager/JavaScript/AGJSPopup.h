#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSPopupExport <JSExport>
- (void)close;
@end

@interface AGJSPopup : NSObject <AGJSPopupExport>
@end
