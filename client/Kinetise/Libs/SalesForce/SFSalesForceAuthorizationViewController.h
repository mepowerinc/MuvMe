#import <UIKit/UIKit.h>

typedef void(^SFAuthorizationCodeSuccessCallback)(NSString* accessToken);
typedef void(^SFAuthorizationCodeCancelCallback)(void);
typedef void(^SFAuthorizationCodeFailureCallback)(NSError* error);

@interface SFSalesForceAuthorizationViewController : UIViewController

-(instancetype) initWithURL:(NSURL*)url success:(SFAuthorizationCodeSuccessCallback)success cancel:(SFAuthorizationCodeCancelCallback)cancel failure:(SFAuthorizationCodeFailureCallback)failure;

@end
