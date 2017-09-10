#import "AGControl.h"
#import "AGGalleryAdapter.h"
#import "AGFeedProtocol.h"

@interface AGGallery : AGControl <AGFeedProtocol>{
    AGGalleryAdapter *adapter;
}

@end
