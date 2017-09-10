#import "Settings.h"

// debug
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif

// device detection
#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_5 (IS_IPHONE && IS_WIDESCREEN)
