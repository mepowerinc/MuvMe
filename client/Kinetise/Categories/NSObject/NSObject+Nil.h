#import <Foundation/Foundation.h>

#define isNil(a) (a == nil || [a isEqual:[NSNull null]])
#define isNotNil(a) (a != nil && ![a isEqual:[NSNull null]])
#define isNotEmpty(a) (a != nil && ![a isEqual:[NSNull null]] && [a isKindOfClass:[NSString class]] && [a length] > 0)
#define isEmpty(a) (a == nil || [a isEqual:[NSNull null]] || ![a isKindOfClass:[NSString class]] || [a length] == 0)