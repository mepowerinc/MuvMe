#import <UIKit/UIKit.h>

@interface UIImagePickerController (Permissions)

+ (void)obtainPermissionForMediaSourceType:(UIImagePickerControllerSourceType)sourceType withSuccessHandler:(void (^) ())successHandler andFailure:(void (^) ())failureHandler;

@end
