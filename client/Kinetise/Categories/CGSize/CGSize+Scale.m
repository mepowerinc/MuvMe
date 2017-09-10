#import "CGSize+Scale.h"

CGSize CGSizeScaleAspectFit(CGSize size, CGSize maxSize){
    CGFloat originalAspectRatio = size.width / size.height;
    CGFloat maxAspectRatio = maxSize.width / maxSize.height;
    CGSize newSize = maxSize;

    if (originalAspectRatio > maxAspectRatio) {
        newSize.height = maxSize.width / originalAspectRatio;
    } else {
        newSize.width = maxSize.height * originalAspectRatio;
    }

    return newSize;
}

CGSize CGSizeScaleAspectFill(CGSize size, CGSize minSize){
    CGFloat scaleWidth = minSize.width / size.width;
    CGFloat scaleHeight = minSize.height / size.height;

    CGFloat scale = fmax(scaleWidth, scaleHeight);
    CGFloat newWidth = size.width * scale;
    CGFloat newHeight = size.height * scale;

    return CGSizeMake(newWidth, newHeight);
}

