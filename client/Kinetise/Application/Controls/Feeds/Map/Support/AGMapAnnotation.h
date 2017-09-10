#import <MapKit/MapKit.h>
#import "AGImageAsset.h"
#import "AGDSFeedItem.h"

@protocol AGMapAnnotationDelegate;

@interface AGMapAnnotation : NSObject <MKAnnotation>

@property(nonatomic, copy) NSString *uniqueIdentifier;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, retain) AGDSFeedItem *dataSource;
@property(nonatomic, assign) CGFloat size;
@property(nonatomic, copy) NSString *uri;

@end