#import "Header.h"
#import "AGMap.h"
#import "AGMapDesc.h"
#import "AGMapAnnotation.h"
#import "AGMapAnnotationView.h"
#import "AGActionManager.h"
#import "AGMapAnnotation.h"
#import "AGGPSLocator.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+UriEncoding.h"
#import "AGFileManager.h"
#import "CGRect+Round.h"
#import "AGApplication+Popup.h"
#import "AGGPSLocator.h"

@interface AGMap () <MKMapViewDelegate>{
    AGControl *indicator;
    UIButton *userTrackingButton;
    MKMapView *mapView;
    NSMutableArray *annotations;
    BOOL hasUserLocation;
}
@property(nonatomic, retain) AGControl *indicator;
@end

@implementation AGMap

@synthesize indicator;

#pragma mark - Initialization

- (void)dealloc {
    self.indicator = nil;
    mapView.delegate = nil;
    mapView.showsUserLocation = NO;
    [mapView.layer removeAllAnimations];
    [mapView removeAnnotations:mapView.annotations];
    [mapView removeOverlays:mapView.overlays];
    [annotations release];
    [super dealloc];
}

- (id)initWithDesc:(AGMapDesc *)descriptor_ {
    self = [super initWithDesc:descriptor_];

    // annotations
    annotations = [[NSMutableArray alloc] init];

    // map
    mapView = (MKMapView *)contentView;
    mapView.delegate = self;

    // user location
    if (descriptor_.showUserLocation || descriptor_.region == mapRegionUserLocation) {
        [AGGPSLocator sharedInstance];
        mapView.showsUserLocation = YES;
    }

    // user tracking button
    if (descriptor_.showUserLocation) {
        MKUserTrackingBarButtonItem *userTrackingButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:mapView];
        userTrackingButton = (UIButton *)[userTrackingButtonItem performSelector:@selector(view)];
        [mapView addSubview:userTrackingButton];
        [userTrackingButtonItem release];
    }

    return self;
}

- (Class)contentClass {
    return [MKMapView class];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    AGMapDesc *desc = (AGMapDesc *)descriptor;

    // indicator
    indicator.frame = CGRectMake(desc.indicatorDesc.positionX+desc.indicatorDesc.marginLeft.value,
                                 desc.indicatorDesc.positionY+desc.indicatorDesc.marginTop.value,
                                 MAX(desc.indicatorDesc.width.value+desc.indicatorDesc.borderLeft.value+desc.indicatorDesc.borderRight.value, 0),
                                 MAX(desc.indicatorDesc.height.value+desc.indicatorDesc.borderTop.value+desc.indicatorDesc.borderBottom.value, 0));

    [indicator setNeedsLayout];

    // map
    CGRect mapRect = CGRectMake(desc.paddingLeft.value+desc.borderLeft.value,
                                desc.paddingTop.value+desc.borderTop.value,
                                MAX(desc.viewportWidth, 0),
                                MAX(desc.viewportHeight, 0));

    // round map frame
    CGRect globalRect = [self convertRect:mapRect toView:nil];
    CGRect globalIntegralRect = CGRectRound(globalRect);
    mapView.frame = [self convertRect:globalIntegralRect fromView:nil];

    // user tracking button
    userTrackingButton.frame = CGRectMake(mapView.bounds.size.width-userTrackingButton.bounds.size.width-6, mapView.bounds.size.height-userTrackingButton.bounds.size.height-6, userTrackingButton.bounds.size.width, userTrackingButton.bounds.size.height);
}

#pragma mark - Assets

- (void)setupAssets {
    [super setupAssets];

    // indicator
    [indicator setupAssets];
}

- (void)loadAssets {
    [super loadAssets];

    // annotations
    for (AGMapAnnotation *annotation in annotations) {
        AGMapAnnotationView *annotationView = (AGMapAnnotationView *)[mapView viewForAnnotation:annotation];
        if (annotationView) {
            [annotationView loadData:annotation];
        }
    }

    // indicator
    [indicator loadAssets];
}

#pragma mark - Reload

- (void)reloadData {
    AGMapDesc *desc = (AGMapDesc *)descriptor;

    // indicator
    [indicator removeFromSuperview];

    if (desc.indicatorDesc) {
        self.indicator = [AGControl controlWithDesc:desc.indicatorDesc];
        indicator.parent = self;
        [contentView addSubview:indicator];
        [indicator setupAssets];
        [indicator loadAssets];
    }

    // existing annotation guids
    NSMutableSet *existingAnnotationGuids = [[NSMutableSet alloc] initWithCapacity:annotations.count];
    for (AGMapAnnotation *annotation in annotations) {
        if (annotation.uniqueIdentifier) [existingAnnotationGuids addObject:annotation.uniqueIdentifier ];
    }

    // new annotation guids
    NSMutableSet *newAnnotationGuids = [[NSMutableSet alloc] initWithCapacity:desc.feed.dataSource.items.count];
    for (AGDSFeedItem *item in desc.feed.dataSource.items) {
        if (item.guid) [newAnnotationGuids addObject:item.guid];
    }

    // annotation guids to update
    NSMutableSet *annotationGuidsToUpdate = [NSMutableSet setWithSet:existingAnnotationGuids];
    [annotationGuidsToUpdate intersectSet:newAnnotationGuids];
    [existingAnnotationGuids release];
    [newAnnotationGuids release];

    // remove annotations
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithCapacity:desc.feed.dataSource.items.count];

    for (int i = 0; i < annotations.count; ++i) {
        AGMapAnnotation *annotation = annotations[i];

        if (!annotation.uniqueIdentifier || ![annotationGuidsToUpdate containsObject:annotation.uniqueIdentifier]) {
            [annotations removeObject:annotation];
            [annotationsToRemove addObject:annotation];
            --i;
        }
    }

    [mapView removeAnnotations:annotationsToRemove];
    [annotationsToRemove release];

    // add or update annotations
    NSMutableArray *annotationsToAdd = [[NSMutableArray alloc] initWithCapacity:desc.feed.dataSource.items.count];

    for (int i = 0; i < desc.feed.dataSource.items.count; ++i) {
        AGDSFeedItem *item = desc.feed.dataSource.items[i];

        desc.itemIndex = i;
        [AGACTIONMANAGER executeVariable:desc.xSrc withSender:desc];
        [AGACTIONMANAGER executeVariable:desc.ySrc withSender:desc];
        [AGACTIONMANAGER executeVariable:desc.pinSrc withSender:desc];

        double latitude = [self scanCoordinate:desc.ySrc.value];
        double longitude = [self scanCoordinate:desc.xSrc.value];

        if (CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(latitude, longitude)) ) {
            if (item.guid && [annotationGuidsToUpdate containsObject:item.guid]) {
                AGMapAnnotation *annotation = nil;

                for (AGMapAnnotation *oldAnnotation in annotations) {
                    if ([oldAnnotation.uniqueIdentifier isEqual:item.guid]) {
                        annotation = oldAnnotation;
                    }
                }

                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                annotation.size = desc.pinSize.value;
                annotation.uri = [desc fullPath:desc.pinSrc.value];
                annotation.dataSource = item;
            } else {
                AGMapAnnotation *annotation = [[AGMapAnnotation alloc] init];

                annotation.uniqueIdentifier = item.guid;
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                annotation.size = desc.pinSize.value;
                annotation.uri = [desc fullPath:desc.pinSrc.value];
                annotation.dataSource = item;

                [annotations addObject:annotation];
                [annotationsToAdd addObject:annotation];
                [annotation release];
            }
        }
    }

    [mapView addAnnotations:annotationsToAdd];
    [annotationsToAdd release];

    // zoom
    if (desc.region == mapRegionPins) {
        [self zoomPins];
    } else if (desc.region == mapRegionUserLocation) {
        [self zoomUserLocation];
    }
}

#pragma mark - Lifecycle

- (double)scanCoordinate:(NSString *)string {
    double result = DBL_MAX;

    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    [scanner scanDouble:&result];
    [scanner release];

    return result;
}

- (void)zoomPins {
    AGMapDesc *desc = (AGMapDesc *)descriptor;

    if (annotations.count && !desc.feed.hasSilentResponse) {
        [mapView setRegion:[self regionForAnnotations:annotations] animated:YES];
    }
}

- (void)zoomUserLocation {
    AGMapDesc *desc = (AGMapDesc *)descriptor;

    if (!desc.feed.hasSilentResponse) {
        if (hasUserLocation && CLLocationCoordinate2DIsValid(mapView.userLocation.coordinate) ) {
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, desc.regionRadius, desc.regionRadius) animated:YES];
        } else if ([AGGPSLocator sharedInstance].hasGPSLocation) {
            [mapView setRegion:MKCoordinateRegionMakeWithDistance([AGGPSLocator sharedInstance].location, desc.regionRadius, desc.regionRadius) animated:YES];
        }
    }
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations_ {
    AGMapDesc *desc = (AGMapDesc *)descriptor;
    
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    
    for (id <MKAnnotation> annotation in annotations_) {
        if (annotation.coordinate.latitude < minLat) {
            minLat = annotation.coordinate.latitude;
        }
        if (annotation.coordinate.longitude < minLon) {
            minLon = annotation.coordinate.longitude;
        }
        if (annotation.coordinate.latitude > maxLat) {
            maxLat = annotation.coordinate.latitude;
        }
        if (annotation.coordinate.longitude > maxLon) {
            maxLon = annotation.coordinate.longitude;
        }
    }
    
    MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat - span.latitudeDelta * 0.5), maxLon - span.longitudeDelta * 0.5);
    CLLocationDistance radius = 0;
    
    for (id <MKAnnotation> annotation in annotations_) {
        radius = MAX(radius, MKMetersBetweenMapPoints(MKMapPointForCoordinate(center), MKMapPointForCoordinate(annotation.coordinate)) );
    }
    radius = MAX(radius, desc.regionRadius);
    
    return MKCoordinateRegionMakeWithDistance(center, radius*2, radius*2);
}

- (void)annotationViewTapped:(UITapGestureRecognizer *)sender {
    if ([sender.view isKindOfClass:[AGMapAnnotationView class]]) {
        AGMapDesc *desc = (AGMapDesc *)descriptor;

        if (desc.showMapPopup) {
            AGMapAnnotationView *annotationView = (AGMapAnnotationView *)sender.view;
            AGMapAnnotation *annotation = (AGMapAnnotation *)annotationView.annotation;

            AGDSFeedItem *feedItem = annotation.dataSource;
            NSInteger itemIndex = [desc.feed.dataSource.items indexOfObject:feedItem];

            AGFeedItemTemplate *itemTemplate = desc.feed.itemTemplates[feedItem.itemTemplateIndex];
            AGControlDesc *itemTemplateControlDesc = [itemTemplate.controlDesc copy];
            itemTemplateControlDesc.itemIndex = itemIndex;
            itemTemplateControlDesc.section = ((AGControlDesc *)self.descriptor).section;
            itemTemplateControlDesc.parent = (AGControlDesc *)self.descriptor;
            [AGAPPLICATION showPopup:itemTemplateControlDesc];
            [itemTemplateControlDesc release];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[AGMapAnnotation class]]) {
        AGMapAnnotationView *annotationView = (AGMapAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:@"AGAnnotationView"];

        if (!annotationView) {
            annotationView = [[[AGMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AGAnnotationView"] autorelease];

            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(annotationViewTapped:)];
            [annotationView addGestureRecognizer:tapGesture];
            [tapGesture release];
        }
        annotationView.annotation = annotation;
        [annotationView loadData:annotation];

        return annotationView;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView_ didAddAnnotationViews:(NSArray *)views {
    AGMapDesc *desc = (AGMapDesc *)descriptor;

    // user location pin
    if (!desc.showUserLocation) {
        MKAnnotationView *annotationView = [mapView_ viewForAnnotation:mapView.userLocation];
        annotationView.hidden = YES;
    }
}

- (void)mapView:(MKMapView *)mapView_ didUpdateUserLocation:(MKUserLocation *)userLocation {
    AGMapDesc *desc = (AGMapDesc *)descriptor;

    // zoom
    if (desc.region == mapRegionUserLocation && !hasUserLocation) {
        hasUserLocation = YES;
        [self zoomUserLocation];
    }
}

@end
