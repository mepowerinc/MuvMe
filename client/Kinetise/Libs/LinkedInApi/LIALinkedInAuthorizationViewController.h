#import "LIALinkedInApplication.h"

typedef void(^LIAAuthorizationCodeSuccessCallback)(NSString* code);
typedef void(^LIAAuthorizationCodeCancelCallback)(void);
typedef void(^LIAAuthorizationCodeFailureCallback)(NSError* error);

@interface LIALinkedInAuthorizationViewController : UIViewController

-(instancetype) initWithApplication:(LIALinkedInApplication*)application success:(LIAAuthorizationCodeSuccessCallback)success cancel:(LIAAuthorizationCodeCancelCallback)cancel failure:(LIAAuthorizationCodeFailureCallback)failure;

@end
