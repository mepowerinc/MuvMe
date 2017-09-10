#import "AGCodeScanner.h"
#import "AGCodeScannerDesc.h"
#import "NSObject+Nil.h"
#import "AGCodeScannerController.h"
#import "AGApplication.h"
#import "AGLocalizationManager.h"
#import "CGSize+Scale.h"
#import "UIImage+Resize.h"
#import "NSString+GUID.h"

@interface AGCodeScanner (){
    NSString *filePath;
}
@property(nonatomic, copy) NSString *filePath;
@end

@implementation AGCodeScanner

@synthesize filePath;

#pragma mark - Initialization

- (void)dealloc {
    self.filePath = nil;
    [super dealloc];
}

- (id)initWithDesc:(AGCodeScannerDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // value
    self.filePath = descriptor_.form.value;

    return self;
}

#pragma mark - Descriptor

- (void)setDescriptor:(AGCodeScannerDesc *)descriptor_ {
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

    if (filePath) {
        [filePath release];
        filePath = nil;
    }

    if (filePath_) {
        filePath = [filePath_ copy];
    }

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

- (void)openScanner {
    if (![AGCodeScannerController isAvailable]) return;

    AGCodeScannerDesc *desc = (AGCodeScannerDesc *)self.descriptor;

    NSMutableArray *metadatTypes = [[[NSMutableArray alloc] init] autorelease];
    if (desc.codeType&AGCodeTypeUPCE) [metadatTypes addObject:AVMetadataObjectTypeUPCECode];
    if (desc.codeType&AGCodeTypeCode39) [metadatTypes addObject:AVMetadataObjectTypeCode39Code];
    if (desc.codeType&AGCodeTypeCode93) [metadatTypes addObject:AVMetadataObjectTypeCode93Code];
    if (desc.codeType&AGCodeTypeCode128) [metadatTypes addObject:AVMetadataObjectTypeCode128Code];
    if (desc.codeType&AGCodeTypeEAN8) [metadatTypes addObject:AVMetadataObjectTypeEAN8Code];
    if (desc.codeType&AGCodeTypeEAN13) [metadatTypes addObject:AVMetadataObjectTypeEAN13Code];
    if (desc.codeType&AGCodeTypePDF417) [metadatTypes addObject:AVMetadataObjectTypePDF417Code];
    if (desc.codeType&AGCodeTypeQR) [metadatTypes addObject:AVMetadataObjectTypeQRCode];
    if (desc.codeType&AGCodeTypeAztec) [metadatTypes addObject:AVMetadataObjectTypeAztecCode];
    if (desc.codeType&AGCodeTypeITF14) [metadatTypes addObject:AVMetadataObjectTypeITF14Code];
    if (desc.codeType&AGCodeTypeDataMatrix) [metadatTypes addObject:AVMetadataObjectTypeDataMatrixCode];

    AGCodeScannerController *viewController = [[AGCodeScannerController alloc] initWithMetadataObjectTypes:metadatTypes andCompletionBlock:^(AGCodeScannerController *scanner, UIImage *image, NSString *resultString) {
        [scanner stopScanning];
        [scanner dismissViewControllerAnimated:YES completion:nil];

        // resize image
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

        // file path
        self.filePath = tempFilePath;

        // value
        desc.form.value = resultString;

        // validate
        if (![desc.form isValid:desc.form.value]) {
            [self validate];
        } else {
            [self invalidate];
        }
    }];

    viewController.title = [AGLOCALIZATION localizedString:@"SCANNER_TITLE"];
    [AGAPPLICATION.navigationController presentViewController:viewController animated:YES completion:nil];
    [viewController release];
}

#pragma mark - Reset

- (void)reset {
    AGCodeScannerDesc *desc = (AGCodeScannerDesc *)descriptor;

    // remove temp file
    if (isNotEmpty(filePath) ) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }

    // value
    self.filePath = desc.form.value;

    // invalidate
    [self invalidate];
}

#pragma mark - Touches

- (void)onTap:(CGPoint)point {
    [self openScanner];

    [super onTap:point];
}

@end
