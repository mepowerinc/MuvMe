#import "NSString+GUID.h"

@implementation NSString (GUID)

+ (NSString *)stringWithGUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *) string autorelease];
}

@end
