#import "AGMapAnnotationView.h"
#import "AGMapAnnotation.h"
#import "AGImageCache.h"
#import "UIImage+Resize.h"
#import "CGSize+Scale.h"
#import "NSString+UriEncoding.h"

@implementation AGMapAnnotationView

@synthesize src;

- (void)dealloc {
    [src clearDelegatesAndCancel];
    self.src = nil;
    [super dealloc];
}

- (id)initWithAnnotation:(AGMapAnnotation *)annotation_ reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation_ reuseIdentifier:reuseIdentifier];

    // image source
    AGImageAsset *imageSource = [[AGImageAsset alloc] initWithUri:[annotation_.uri uriString] ];
    self.src = imageSource;
    imageSource.delegate = self;
    [imageSource release];

    // anchor
    self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);

    return self;
}

- (void)loadData:(AGMapAnnotation *)annotation_ {
    src.uri = [annotation_.uri uriString];
    src.prefferedImageSize = annotation_.size;

    [src execute];
}

- (void)setImage:(UIImage *)image_ {
    [super setImage:image_];

    if (image_) {
        AGMapAnnotation *annotation = (AGMapAnnotation *)self.annotation;

        // frame
        CGSize originalSize = image_.size;
        CGSize scaledSize = CGSizeScaleAspectFit(originalSize, CGSizeMake(annotation.size, annotation.size));
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, scaledSize.width, scaledSize.height);
    }
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoad:(AGAsset *)asset_ {
    if (asset_ == src && asset_.assetType != assetFile) {
        self.image = nil;
    }
}

- (void)asset:(AGAsset *)asset_ didLoad:(UIImage *)object {
    if (asset_ == src) {
        self.image = object;
    }
}

- (void)asset:(AGAsset *)asset_ didFail:(NSError *)error {
    if (asset_ == src) {
        self.image = AG_ERROR_IMAGE;
    }
}

@end
