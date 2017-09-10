#import <JavaScriptCore/JavaScriptCore.h>
#import "AGControlDesc.h"

@protocol AGJSControlExport <JSExport>
@property(nonatomic, readonly) NSString* identifier;
@property(nonatomic, copy) NSString *backgroundColor;
@property(nonatomic, copy) NSString *textColor;
@property(nonatomic, copy) NSString *text;
@end

@interface AGJSControl : NSObject <AGJSControlExport>
- (id)initWithControlId:(NSString*)controlId;
- (id)initWithControlDesc:(AGControlDesc*)controlDesc;
@end
