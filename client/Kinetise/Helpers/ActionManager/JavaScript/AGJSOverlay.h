#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSOverlayExport <JSExport>
- (void)open:(NSString *)overlayId;
- (void)close;
@end

@interface AGJSOverlay : NSObject <AGJSOverlayExport>
@end
