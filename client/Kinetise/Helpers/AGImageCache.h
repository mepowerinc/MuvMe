#import "NSObject+Singleton.h"

#define AGIMAGECACHE [AGImageCache sharedInstance]

@interface AGImageCache : NSObject {
    NSMutableArray *keysArray;
    NSMutableArray *imagesArray;
    NSInteger cacheSize;
    NSInteger maxMemoryCapacity;
    NSInteger usedMemoryCapacity;
}

@property(nonatomic, assign) NSInteger cacheSize;

SINGLETON_INTERFACE(AGImageCache)

- (UIImage *)imageForKey:(NSString *)key;
- (BOOL)hasImageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (NSUInteger)numberOfImages;
- (void)removeImageForKey:(NSString *)key;
- (void)removeAllImages;

@end
