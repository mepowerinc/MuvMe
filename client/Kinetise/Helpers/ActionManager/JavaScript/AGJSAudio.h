#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSAudioExport <JSExport>
- (void)play:(NSDictionary *)request :(NSNumber *)volume :(NSNumber *)loop;
- (void)stop;
@end

@interface AGJSAudio : NSObject <AGJSAudioExport>
@end
