#import "AGActionManager.h"

@interface AGActionManager (Logic)

- (NSString *)getLocalValue:(id)sender :(id)object :(NSString *)key;
- (NSString *)setLocalValue:(id)sender :(id)object :(NSString *)key :(NSString *)value;
- (void)saveFormToLocalValues:(id)sender :(id)object :(NSString *)controlAction :(NSString *)postAction;
- (id)condition:(id)sender :(id)object :(NSNumber *)condition :(NSString *)yesAction :(NSString *)noAction;
- (id)if:(id)sender :(id)object :(NSNumber *)condition :(NSString *)yesAction :(NSString *)noAction;
- (NSNumber *)equal:(id)sender :(id)object :(id)arg1 :(id)arg2;
- (NSNumber *)greater:(id)sender :(id)object :(id)arg1 :(id)arg2;
- (NSNumber *)lower:(id)sender :(id)object :(id)arg1 :(id)arg2;
- (NSNumber *)equalOrGreater:(id)sender :(id)object :(id)arg1 :(id)arg2;
- (NSNumber *)equalOrLower:(id)sender :(id)object :(id)arg1 :(id)arg2;
- (NSNumber *)not:(id)sender :(id)object :(id)arg1;
- (NSNumber *)and:(id)sender :(id)object :(id)arg1 :(id)arg2;
- (NSNumber *)or:(id)sender :(id)object :(id)arg1 :(id)arg2;

@end
