#import "MBProgressHUD.h"

@interface MBProgressHUD (Hide)

-(void) hide:(BOOL)animated completion:(MBProgressHUDCompletionBlock)completion;
-(void) hide:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(MBProgressHUDCompletionBlock)completion;

@end
