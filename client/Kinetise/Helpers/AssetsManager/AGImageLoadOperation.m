#import "AGImageLoadOperation.h"
#import "CGSize+Scale.h"
#import "UIImage+Resize.h"
#import "UIImage+Decode.h"

@interface AGImageLoadOperation (){
    NSInteger prefferedImageSize;
    NSData *data;
}
@property(nonatomic, retain) NSData *data;
@end

@implementation AGImageLoadOperation

@synthesize data;
@synthesize delegate;

- (void)dealloc {
    self.data = nil;
    self.delegate = nil;
    [super dealloc];
}

- (id)initWithData:(NSData *)data_ andPrefferedSize:(NSInteger)prefferedImageSize_ {
    self = [super init];

    prefferedImageSize = prefferedImageSize_;
    self.data = data_;

    return self;
}

- (void)cancel {
    delegate = nil;
    [super cancel];
}

- (void)startSynchronous {
    [self main];
}

- (void)clearDelegatesAndCancel {
    self.delegate = nil;
    [self cancel];
}

#pragma mark - Main

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) return;

        // image
        UIImage *image = [[[UIImage alloc] initWithData:data scale:AG_IMAGE_SCALE] autorelease];

        // validate image
        if (!image) {
            [delegate loadImage:self didFail:nil];
            return;
        }

        if (self.isCancelled) return;

        // resize image
        CGFloat scale = image.scale;
        CGFloat invScale = 1.0f/scale;
        CGSize originalSize = CGSizeMake(image.size.width, image.size.height);
        CGSize scaledSize = CGSizeScaleAspectFit(originalSize, CGSizeMake(prefferedImageSize*invScale, prefferedImageSize*invScale));

        if (originalSize.width > scaledSize.width || originalSize.height > scaledSize.height) {
            image = [image resizedImage:scaledSize];
        }

        if (self.isCancelled) return;

        // force image decompression
        image = [image decodedImage];

        if (self.isCancelled) return;

        // delegate
        if (![NSThread isMainThread]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (image) {
                    [delegate loadImage:self didLoad:image];
                } else {
                    [delegate loadImage:self didFail:nil];
                }
            }];
        } else {
            if (image) {
                [delegate loadImage:self didLoad:image];
            } else {
                [delegate loadImage:self didFail:nil];
            }
        }
    }
}

@end
