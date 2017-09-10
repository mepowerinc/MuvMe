#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString *)hex {
    NSScanner *scanner = [NSScanner scannerWithString:hex ];
    unsigned color;
    [scanner scanHexInt:&color];

    if (hex.length == 8) {
        return [UIColor colorWithRed:(((CGFloat)((color & 0xFF0000) >> 16)) / 255.0f)
                               green:(((CGFloat)((color & 0xFF00) >>  8)) / 255.0f)
                                blue:(((CGFloat)(color & 0xFF)) / 255.0f)
                               alpha:1.0f];
    } else if (hex.length == 10) {
        return [UIColor colorWithRed:(((CGFloat)((color & 0xFF0000) >>  16)) / 255.0f)
                               green:(((CGFloat)((color & 0xFF00) >> 8)) / 255.0f)
                                blue:(((CGFloat)(color & 0xFF)) / 255.0f)
                               alpha:(((CGFloat)((color & 0xFF000000) >> 24)) / 255.0f)];
    }

    return [UIColor clearColor];
}

@end
