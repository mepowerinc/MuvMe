#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSStorageExport <JSExport>
- (NSString *)get:(NSString *)key;
- (void)set:(NSString *)key :(id)value;
- (void)insert:(NSString *)controlId;
@end

@interface AGJSStorage : NSObject <AGJSStorageExport>
@end
