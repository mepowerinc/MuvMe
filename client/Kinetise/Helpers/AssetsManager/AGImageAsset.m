#import "AGImageAsset.h"
#import "AGFileManager.h"
#import "AGImageCache.h"
#import "AGAssetsManager.h"
#import "AGLocalStorage.h"
#import "NSString+URL.h"

@implementation AGImageAsset

@synthesize prefferedImageSize;

#pragma mark - Initialization

- (id)initWithUri:(NSString *)uri_ {
    self = [super initWithUri:uri_];

    // data type
    assetDataType = assetImageData;

    return self;
}

#pragma mark - Lifecycle

+ (UIImage *)imageWithAsset:(NSString *)assetPath {
    // size
    NSInteger imageSize = 2048;
    imageSize = imageSize *[UIScreen mainScreen].scale;
    imageSize--;
    imageSize |= imageSize >> 1;
    imageSize |= imageSize >> 2;
    imageSize |= imageSize >> 4;
    imageSize |= imageSize >> 8;
    imageSize |= imageSize >> 16;
    imageSize++;
    if (imageSize < AG_MIN_IMAGE_SIZE) imageSize = AG_MIN_IMAGE_SIZE;
    if (imageSize > AG_MAX_IMAGE_SIZE) imageSize = AG_MAX_IMAGE_SIZE;

    // file name
    NSString *fileNameWithExtension = [[assetPath stringByDeletingURLQuery] substringFromIndex:[@"assets://" length] ];
    NSString *fileName = [fileNameWithExtension stringByDeletingPathExtension];
    NSString *fileExtension = [fileNameWithExtension pathExtension];
    NSString *filePath = nil;
    NSString *fileNameWithSuffix = nil;

    // find file
    for (NSInteger i = imageSize; i >= AG_MIN_IMAGE_SIZE; i *= 0.5f) {
        fileNameWithSuffix = [NSString stringWithFormat:@"%@_%zd.%@", fileName, i, fileExtension];
        filePath = [AGFILEMANAGER pathForResource:fileNameWithSuffix];

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            break;
        }
    }

    UIImage *image = nil;
    if ([AGIMAGECACHE hasImageForKey:filePath]) {
        image = [AGIMAGECACHE imageForKey:filePath];
    } else {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        image = [[[UIImage alloc] initWithData:data scale:AG_IMAGE_SCALE] autorelease];
        [data release];
    }

    return image;
}

+ (UIImage *)imageWithLocal:(NSString *)filePath {
    NSString *fileName = [filePath substringFromIndex:[@"local://" length]];
    filePath = [AGLOCALSTORAGE attachmentPath:fileName];

    UIImage *image = nil;
    if ([AGIMAGECACHE hasImageForKey:filePath]) {
        image = [AGIMAGECACHE imageForKey:filePath];
    } else {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        image = [[[UIImage alloc] initWithData:data scale:AG_IMAGE_SCALE] autorelease];
        [data release];
    }

    return image;
}

- (void)setPrefferedImageSize:(NSInteger)prefferedImageSize_ {
    if (prefferedImageSize == prefferedImageSize_) return;

    prefferedImageSize = prefferedImageSize_ *[UIScreen mainScreen].scale;
    prefferedImageSize--;
    prefferedImageSize |= prefferedImageSize >> 1;
    prefferedImageSize |= prefferedImageSize >> 2;
    prefferedImageSize |= prefferedImageSize >> 4;
    prefferedImageSize |= prefferedImageSize >> 8;
    prefferedImageSize |= prefferedImageSize >> 16;
    prefferedImageSize++;
    if (prefferedImageSize < AG_MIN_IMAGE_SIZE) prefferedImageSize = AG_MIN_IMAGE_SIZE;
    if (prefferedImageSize > AG_MAX_IMAGE_SIZE) prefferedImageSize = AG_MAX_IMAGE_SIZE;
}

#pragma mark - Execution

- (void)execute {
    [super execute];

    // asset
    if (assetType == assetFile) {
        // file name
        NSString *fileNameWithExtension = [[uri stringByDeletingURLQuery] substringFromIndex:[@"assets://" length] ];
        NSString *fileName = [fileNameWithExtension stringByDeletingPathExtension];
        NSString *fileExtension = [fileNameWithExtension pathExtension];
        NSString *filePath = nil;
        NSString *fileNameWithSuffix = nil;

        // find file
        for (NSInteger i = prefferedImageSize; i >= AG_MIN_IMAGE_SIZE; i *= 0.5f) {
            fileNameWithSuffix = [NSString stringWithFormat:@"%@_%zd.%@", fileName, i, fileExtension];
            filePath = [AGFILEMANAGER pathForResource:fileNameWithSuffix];

            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                break;
            }
        }

        // image
        UIImage *image = nil;

        if (cachePolicy != cachePolicyDoNotCache) {
            image = [AGIMAGECACHE imageForKey:filePath];
        } else {
            if ([AGIMAGECACHE hasImageForKey:filePath]) {
                image = [AGIMAGECACHE imageForKey:filePath];
            } else {
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                image = [[[UIImage alloc] initWithData:data scale:AG_IMAGE_SCALE] autorelease];
                [data release];
            }
        }

        // delegate
        if (image) {
            [delegate asset:self didLoad:image];
        } else {
            [delegate asset:self didFail:nil];
        }
    }

    // local
    if (assetType == assetLocalStorage) {
        // file path
        NSString *fileName = [[uri stringByDeletingURLQuery] substringFromIndex:[@"local://" length]];
        NSString *filePath = [AGLOCALSTORAGE attachmentPath:fileName];

        // image
        UIImage *image = nil;

        if (cachePolicy != cachePolicyDoNotCache) {
            image = [AGIMAGECACHE imageForKey:filePath];
        } else {
            if ([AGIMAGECACHE hasImageForKey:filePath]) {
                image = [AGIMAGECACHE imageForKey:filePath];
            } else {
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                image = [[[UIImage alloc] initWithData:data scale:AG_IMAGE_SCALE] autorelease];
                [data release];
            }
        }

        // delegate
        if (image) {
            [delegate asset:self didLoad:image];
        } else {
            [delegate asset:self didFail:nil];
        }
    }
}

- (void)cancel {
    [super cancel];
    [imageOperation clearDelegatesAndCancel];
    imageOperation = nil;
}

#pragma mark - Response

- (void)processData:(NSData *)data asynchronous:(BOOL)asynchronous {
    if (imageOperation) {
        [imageOperation clearDelegatesAndCancel];
    }

    imageOperation = [[AGImageLoadOperation alloc] initWithData:data andPrefferedSize:prefferedImageSize];
    imageOperation.delegate = self;

    if (asynchronous) {
        [[AGAssetsManager sharedInstance].imageProcessingQueue addOperation:imageOperation];
        [imageOperation release];
    } else {
        [imageOperation autorelease];
        [imageOperation startSynchronous];
    }
}

#pragma mark - AGImageLoadOperationDelegate

- (void)loadImage:(AGImageLoadOperation *)operation didLoad:(UIImage *)image {
    // delegate
    [delegate asset:self didLoad:image];

    // operation
    imageOperation = nil;

    // finish operation
    [self finishProcessingData];
}

- (void)loadImage:(AGImageLoadOperation *)operation didFail:(NSError *)error {
    // delegate
    [delegate asset:self didFail:error];

    // operation
    imageOperation = nil;

    // finish operation
    [self finishProcessingData];
}

@end
