#import <UIKit/UIKit.h>

typedef void (^AGPaymentSuccessCallback)(void);
typedef void (^AGPaymentCancelCallback)(void);
typedef void (^AGPaymentFailureCallback)(void);

@interface AGPaymentViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)url success:(AGPaymentSuccessCallback)success cancel:(AGPaymentCancelCallback)cancel failure:(AGPaymentFailureCallback)failure;

@end
