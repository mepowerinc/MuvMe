#import <JavaScriptCore/JavaScriptCore.h>

@protocol AGJSLocalizationExport <JSExport>
@property(nonatomic, copy) NSString *language;
- (NSString *)localize:(NSString *)text;
@end

@interface AGJSLocalization : NSObject <AGJSLocalizationExport>

@end
