#import "UIImagePickerController+Permissions.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@implementation UIImagePickerController (Permissions)

+ (void)obtainPermissionForMediaSourceType:(UIImagePickerControllerSourceType)sourceType withSuccessHandler:(void (^) ())successHandler andFailure:(void (^) ())failureHandler {
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary || sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        // denied when photo disabled, authorized when photos is enabled. Not affected by camera
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
            case PHAuthorizationStatusAuthorized: {
                if (successHandler)
                    dispatch_async(dispatch_get_main_queue(), ^{ successHandler(); });
            }; break;

            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied: {
                if (failureHandler)
                    dispatch_async(dispatch_get_main_queue(), ^{ failureHandler(); });
            }; break;

            default:
                break;
            }
        }];
    } else if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        // checks for Camera access:
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

        switch (status) {
        case AVAuthorizationStatusAuthorized: {
            if (successHandler)
                dispatch_async(dispatch_get_main_queue(), ^{ successHandler(); });
        }; break;

        case AVAuthorizationStatusNotDetermined: {
            // seek access first:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        if (successHandler)
                            dispatch_async(dispatch_get_main_queue(), ^{ successHandler(); });
                    } else {
                        if (failureHandler)
                            dispatch_async(dispatch_get_main_queue(), ^{ failureHandler(); });
                    }
                }];
        }; break;

        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:

        default: {
            if (failureHandler)
                dispatch_async(dispatch_get_main_queue(), ^{ failureHandler(); });
        }; break;
        }
    } else {
        NSAssert(NO, @"Permission type not found");
    }
}

@end
