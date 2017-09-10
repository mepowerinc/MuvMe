#import "GPGoogleApplication.h"

@interface GPGoogleAuthorizationViewController : UIViewController

-(instancetype) initWithApplication:(GPGoogleApplication*)application success:(void (^)(NSDictionary*))success cancel:(void (^)(void))cancel failure:(void (^)(NSError*))failure;

@end
