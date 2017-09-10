#import "AGControlDesc.h"
#import "AGFeedClientProtocol.h"

@interface AGGalleryDesc : AGControlDesc <AGFeedClientProtocol>{
    AGFeed *feed;
    NSMutableArray *galleryElements;
}

@property(nonatomic, readonly) NSMutableArray *galleryElements;

@end
