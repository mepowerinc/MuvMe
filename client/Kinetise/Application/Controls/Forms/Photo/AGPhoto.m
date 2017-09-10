#import "AGPhoto.h"
#import "AGApplication.h"
#import "CGSize+Scale.h"
#import "UIImage+Resize.h"
#import "AGFormClientProtocol.h"
#import "AGForm.h"
#import "AGPhotoDesc.h"
#import "AGLayoutManager.h"
#import "NSString+GUID.h"
#import "NSObject+Nil.h"
#import "AGLocalizationManager.h"
#import "UIImagePickerController+Permissions.h"
#import <RMUniversalAlert/RMUniversalAlert.h>

@interface AGPhoto () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    NSString *filePath;
}
@property(nonatomic, copy) NSString *filePath;
@end

@implementation AGPhoto

@synthesize filePath;

#pragma mark - Initialization

- (void)dealloc {
    self.filePath = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGPhotoDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // value
    self.filePath = descriptor_.form.value;

    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGPhotoDesc *)descriptor_ {
    if (!descriptor) {
        [super setDescriptor:descriptor_];
        return;
    } else {
        [super setDescriptor:descriptor_];
        if (!descriptor_) return;
    }

    // value
    self.filePath = descriptor_.form.value;
}

#pragma mark - Form

- (void)setValue:(NSString *)value_ {
    self.filePath = value_;
}

- (void)setFilePath:(NSString *)filePath_ {
    if ([filePath isEqualToString:filePath_]) return;

    AGPhotoDesc *desc = (AGPhotoDesc *)descriptor;

    if (filePath) {
        [filePath release];
        filePath = nil;
    }

    if (filePath_) {
        filePath = [filePath_ copy];
    }

    // value
    desc.form.value = filePath;

    // image
    if (filePath) {
        NSString *fileExtension = [filePath pathExtension];
        NSString *tempFilePath = [filePath stringByDeletingPathExtension];
        NSString *thumbFilePath = [NSString stringWithFormat:@"%@_thumb.%@", tempFilePath, fileExtension];
        UIImage *photoImage = [[[UIImage alloc] initWithContentsOfFile:thumbFilePath] autorelease];

        [self setAppearance:@"image" withObject:photoImage forState:UIControlStateFilled];
        [self setAppearance:@"image" withObject:photoImage forState:UIControlStateHighlighted|UIControlStateFilled];
        self.filled = YES;
    } else {
        [self setAppearance:@"image" withObject:nil forState:UIControlStateFilled];
        [self setAppearance:@"image" withObject:nil forState:UIControlStateHighlighted|UIControlStateFilled];
        self.filled = NO;
    }
}

#pragma mark - Lifecycle

- (void)openGallery {
    NSString *cameraTitle = [AGLOCALIZATION localizedString:@"OPEN_PHOTO_CAMERA"];
    NSString *libraryTitle = [AGLOCALIZATION localizedString:@"OPEN_PHOTO_LIBRARY"];
    NSString *cancelTitle = [AGLOCALIZATION localizedString:@"OPEN_PHOTO_CANCEL"];

    __block AGPhoto *weakSelf = self;

    [RMUniversalAlert showActionSheetInViewController:AGAPPLICATION.navigationController
                                            withTitle:nil
                                              message:nil
                                    cancelButtonTitle:cancelTitle
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@[cameraTitle, libraryTitle]
                   popoverPresentationControllerBlock:nil
                                             tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
        if (buttonIndex >= alert.firstOtherButtonIndex) {
            buttonIndex = buttonIndex - alert.firstOtherButtonIndex;

            UIImagePickerControllerSourceType sourceType = NSNotFound;

            if (buttonIndex == 0) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                }
            } else if (buttonIndex == 1) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                }
            }

            if (sourceType != NSNotFound) {
                [UIImagePickerController obtainPermissionForMediaSourceType:sourceType withSuccessHandler:^{
                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                    imagePickerController.sourceType = sourceType;
                    imagePickerController.allowsEditing = NO;
                    imagePickerController.delegate = weakSelf;
                    [AGAPPLICATION.navigationController presentViewController:imagePickerController animated:YES completion:nil];
                    [imagePickerController release];
                } andFailure:^{
                    NSString *titleKey = sourceType == UIImagePickerControllerSourceTypeCamera ? @"CAMERA_ACCESS_DENIED_TITLE" : @"PHOTO_LIBRARY_ACCESS_DENIED_TITLE";
                    NSString *messageKey = sourceType == UIImagePickerControllerSourceTypeCamera ? @"CAMERA_ACCESS_DENIED_MESSAGE" : @"PHOTO_LIBRARY_ACCESS_DENIED_MESSAGE";
                    NSString *settingsKey = sourceType == UIImagePickerControllerSourceTypeCamera ? @"CAMERA_ACCESS_DENIED_SETTINGS" : @"PHOTO_LIBRARY_ACCESS_DENIED_SETTINGS";
                    NSString *closeKey = sourceType == UIImagePickerControllerSourceTypeCamera ? @"CAMERA_ACCESS_DENIED_CLOSE" : @"PHOTO_LIBRARY_ACCESS_DENIED_CLOSE";

                    [RMUniversalAlert showAlertInViewController:AGAPPLICATION.navigationController
                                                      withTitle:[AGLOCALIZATION localizedString:titleKey]
                                                        message:[AGLOCALIZATION localizedString:messageKey]
                                              cancelButtonTitle:[AGLOCALIZATION localizedString:settingsKey]
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@[ [AGLOCALIZATION localizedString:closeKey] ]
                                                       tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                        if (buttonIndex == alert.cancelButtonIndex) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }
                    ];
                }];
            }
        }
    }];
}

#pragma mark - Reset

- (void)reset {
    AGPhotoDesc *desc = (AGPhotoDesc *)descriptor;

    // remove temp file
    if (isNotEmpty(filePath) ) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }

    // value
    self.filePath = desc.form.value;

    // validation
    [self invalidate];
}

#pragma mark - Touches

- (void)onTap:(CGPoint)point {
    [self openGallery];

    [super onTap:point];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    void (^completion)(void) = ^(void){
        AGPhotoDesc *desc = (AGPhotoDesc *)self.descriptor;

        // resize image
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize originalSize = image.size;
        CGSize scaledSize = CGSizeScaleAspectFit(originalSize, AG_MAX_PHOTO_SIZE);
        image = [image resizedImage:scaledSize];

        // save base64 form value
        NSData *imageData = UIImageJPEGRepresentation(image, 0.75f);

        // write file and save path
        NSString *guid = [NSString stringWithGUID];
        NSString *dirPath = FILE_PATH_TEMP(@"Photos");
        NSString *tempFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", guid] ];
        NSString *tempThumbFilePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_thumb.jpg", guid] ];

        // write image
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [imageData writeToFile:tempFilePath options:0 error:nil];

        // write thumbnail
        CGSize screenSize = CGSizeMake(self.bounds.size.width *[UIScreen mainScreen].scale, self.bounds.size.height *[UIScreen mainScreen].scale);
        originalSize = image.size;
        if (desc.sizeMode == sizeModeLongedge) {
            scaledSize = CGSizeScaleAspectFit(originalSize, screenSize);
        } else {
            scaledSize = CGSizeScaleAspectFill(originalSize, screenSize);
        }
        UIImage *thumbnail = [image resizedImage:scaledSize];
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.9f);
        [thumbnailData writeToFile:tempThumbFilePath options:0 error:nil];

        // value
        self.filePath = tempFilePath;

        // validate
        if (![desc.form isValid:desc.form.value]) {
            [self validate];
        } else {
            [self invalidate];
        }
    };

    // dismiss
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:completion];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // dismiss
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
