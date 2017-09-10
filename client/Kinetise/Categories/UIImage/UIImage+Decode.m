#import "UIImage+Decode.h"

@implementation UIImage (Decode)

+ (UIImage *)imageByDecodingData:(NSData *)imageData withFormat:(NSImageFormat)imageFormat andScale:(CGFloat)scale {
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)imageData);

    if (!dataProvider) return nil;

    CGImageRef imageRef = nil;
    if (imageFormat == NSImageFormatPNG) {
        imageRef = CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
    } else if (imageFormat == NSImageFormatJPEG) {
        imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
    }
    CGDataProviderRelease(dataProvider);

    if (!imageRef) return nil;

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(NULL,
                                                      width,
                                                      height,
                                                      8,
                                                      width*4,
                                                      colorSpace,
                                                      (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little));
    CGColorSpaceRelease(colorSpace);

    if (!imageContext) {
        CGImageRelease(imageRef);
        return nil;
    }

    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef outputImage = CGBitmapContextCreateImage(imageContext);
    CGContextRelease(imageContext);
    CGImageRelease(imageRef);

    if (!outputImage) return nil;

    UIImage *image = [UIImage imageWithCGImage:outputImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(outputImage);

    return image;
}

- (UIImage *)decodedImage {
    CGImageRef imageRef = self.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 8,
                                                 width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    UIImage *decompressedImage = [[[UIImage alloc] initWithCGImage:decompressedImageRef scale:self.scale orientation:self.imageOrientation] autorelease];
    CGImageRelease(decompressedImageRef);

    return decompressedImage;
}

@end
