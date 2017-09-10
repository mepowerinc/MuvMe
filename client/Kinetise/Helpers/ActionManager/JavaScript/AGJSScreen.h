#import <JavaScriptCore/JavaScriptCore.h>
#import "AGJSControl.h"

@protocol AGJSScreenExport <JSExport>
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSDictionary *context;
- (AGJSControl *)control:(NSString *)controlId;
- (void)go:(id)screenId :(id)transition;
- (void)back:(id)screenIdOrSteps :(id)transition;
- (void)prev:(id)transition;
- (void)next:(id)transition;
- (void)refresh;
- (void)reload;
@end

@interface AGJSScreen : NSObject <AGJSScreenExport>
@end
