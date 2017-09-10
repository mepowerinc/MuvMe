#import <MapKit/MapKit.h>
#import "AGImageAsset.h"
#import "AGMapAnnotation.h"

@interface AGMapAnnotationView : MKAnnotationView <AGAssetDelegate>

@property(nonatomic, retain) AGImageAsset *src;

- (void)loadData:(AGMapAnnotation *)annotation;

@end
