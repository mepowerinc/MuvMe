#import "AGImageCache.h"

@implementation AGImageCache

SINGLETON_IMPLEMENTATION(AGImageCache)

@synthesize cacheSize;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [keysArray release];
    [imagesArray release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // cache size
    cacheSize = 64;

    // storage
    keysArray = [[NSMutableArray alloc] initWithCapacity:cacheSize];
    imagesArray = [[NSMutableArray alloc] initWithCapacity:cacheSize];

    // notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeAllImages)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeAllImages)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];

    return self;
}

- (UIImage *)imageForKey:(NSString *)key {
    if (!key) return nil;

    NSString *filePath = key;

    UIImage *image = nil;
    NSUInteger index = [keysArray indexOfObject:key];
    if (index == NSNotFound) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        image = [[UIImage alloc] initWithData:data scale:AG_IMAGE_SCALE];
        [data release];
        if (image) [self addImage:image forKey:key];
        [image release];
    } else {
        image = [imagesArray objectAtIndex:index];

        // move heavy used images to top of stack
        [imagesArray exchangeObjectAtIndex:0 withObjectAtIndex:index];
        [keysArray exchangeObjectAtIndex:0 withObjectAtIndex:index];
    }

    return image;
}

- (BOOL)hasImageForKey:(NSString *)key {
    return [keysArray indexOfObject:key] != NSNotFound;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    if (!image || !key) return;

    NSUInteger index = [keysArray indexOfObject:key];
    if (index == NSNotFound) {
        [self addImage:image forKey:key];
    }
}

- (NSUInteger)numberOfImages {
    return [imagesArray count];
}

- (void)removeImageForKey:(NSString *)key {
    if (!key) return;

    NSInteger index = [keysArray indexOfObject:key];
    if (index != NSNotFound) {
        [keysArray removeObjectAtIndex:index];
        [imagesArray removeObjectAtIndex:index];
    }
}

- (void)removeAllImages {
    [keysArray removeAllObjects];
    [imagesArray removeAllObjects];
}

#pragma mark - Private

- (void)addImage:(UIImage *)image forKey:(NSString *)key {
    [keysArray insertObject:key atIndex:0];
    [imagesArray insertObject:image atIndex:0];

    if (keysArray.count > cacheSize) {
        [keysArray removeLastObject];
        [imagesArray removeLastObject];
    }

    // memory usage
    //size_t imageSize = CGImageGetBytesPerRow(image.CGImage) * CGImageGetHeight(image.CGImage);
}

@end
