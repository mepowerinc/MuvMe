#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, NSImageFormat){
    NSImageFormatPNG,
    NSImageFormatJPEG
};

@interface UIImage (Decode)

+ (UIImage *)imageByDecodingData:(NSData *)imageData withFormat:(NSImageFormat)imageFormat andScale:(CGFloat)scale;
- (UIImage *)decodedImage;

@end
