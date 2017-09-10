#import "AGAsset.h"
#import "AGImageLoadOperation.h"

@interface AGImageAsset : AGAsset <AGImageLoadOperationDelegate>{
    AGImageLoadOperation *imageOperation;
    NSInteger prefferedImageSize;
}

@property(nonatomic, assign) NSInteger prefferedImageSize;

+ (UIImage *)imageWithAsset:(NSString *)assetPath;
+ (UIImage *)imageWithLocal:(NSString *)filePath;

@end
