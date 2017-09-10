#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)resizedImage:(CGSize)newSize;
- (UIImage *)resizedImageWithSize:(CGSize)newSize andInterpolationQuality:(CGInterpolationQuality)quality;

@end
