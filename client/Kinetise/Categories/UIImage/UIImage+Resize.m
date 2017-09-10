#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImage:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (UIImage *)resizedImageWithSize:(CGSize)newSize andInterpolationQuality:(CGInterpolationQuality)quality {
    newSize = CGSizeMake(newSize.width, newSize.height);

    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;

    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, quality);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);

    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);

    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];

    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();

    return newImage;
}

@end