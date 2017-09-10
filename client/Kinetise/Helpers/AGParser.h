#import "AGApplicationDesc.h"

@interface AGParser : NSObject

+ (AGApplicationDesc *)parse:(NSString *)xmlFilePath;
+ (Class)classWithName:(NSString *)name;

@end
