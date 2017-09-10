#import "AGActionManager.h"

@interface AGActionManager (Text)

- (NSString *)merge:(id)sender :(id)object :(NSArray *)strings;
- (NSString *)regex:(id)sender :(id)object :(NSString *)string :(NSString *)regexName;
- (NSString *)encode:(id)sender :(id)object :(NSString *)algorithm :(NSString *)input;
- (NSString *)decode:(id)sender :(id)object :(NSString *)algorithm :(NSString *)input;

- (void)increaseTextMultiplier:(id)sender :(id)object :(NSString *)stepString;
- (void)decreaseTextMultiplier:(id)sender :(id)object :(NSString *)stepString;

@end
