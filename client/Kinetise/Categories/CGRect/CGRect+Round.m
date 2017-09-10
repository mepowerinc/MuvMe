#include "CGRect+Round.h"

CGRect CGRectRound(CGRect rect){
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat invScale = 1.0f/scale;

    return CGRectMake(
        roundf(rect.origin.x * scale) * invScale,
        roundf(rect.origin.y * scale) * invScale,
        roundf(rect.size.width * scale) * invScale,
        roundf(rect.size.height * scale) * invScale
        );
}