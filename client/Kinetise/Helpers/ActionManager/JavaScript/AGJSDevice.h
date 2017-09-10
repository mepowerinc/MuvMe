#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSDeviceExport <JSExport>
@property(nonatomic, readonly) NSString *uuid;
@end

@interface AGJSDevice : NSObject <AGJSDeviceExport>

@end
