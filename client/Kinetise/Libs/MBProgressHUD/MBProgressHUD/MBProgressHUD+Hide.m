#import "MBProgressHUD+Hide.h"

@implementation MBProgressHUD (Hide)

-(void) hide:(BOOL)animated completion:(MBProgressHUDCompletionBlock)completion{
    self.completionBlock = completion;
    [self hide:animated];
}

-(void) hide:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(MBProgressHUDCompletionBlock)completion{
    self.completionBlock = completion;
    [self hide:animated afterDelay:delay];
}

@end
