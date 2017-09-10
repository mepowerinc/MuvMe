#import "AGActionManager.h"

@interface AGActionManager (Controls)

- (AGControlDesc *)getControl:(id)sender :(id)object :(NSString *)controlId;
- (id)getContext:(id)sender :(id)object;
- (NSString *)getActiveItemField:(id)sender :(id)object :(NSString *)field;
- (NSString *)getItemField:(id)sender :(id)object :(NSString *)field;
- (AGControlDesc *)getItem:(id)sender :(id)object;
- (NSString *)getValue:(id)sender :(id)object;
- (void)setValue:(id)sender :(id)object :(NSString *)value;

@end
