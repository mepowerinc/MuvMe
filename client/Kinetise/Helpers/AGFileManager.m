#import "AGFileManager.h"
#import "AGLocalizationManager.h"

@interface AGFileManager ()
@property(nonatomic, retain) NSBundle *bundle;
@property(nonatomic, copy) NSString *resourcesFilePath;
@end

@implementation AGFileManager

SINGLETON_IMPLEMENTATION(AGFileManager)

@synthesize bundle;
@synthesize resourcesFilePath;

- (void)dealloc {
    self.bundle = nil;
    self.resourcesFilePath = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    // bundle
    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Resources.bundle"];
    self.bundle = [NSBundle bundleWithPath:frameworkBundlePath];

    // determine resources path
    self.resourcesFilePath = [self.bundle.bundlePath stringByAppendingPathComponent:@""];
    
    return self;
}

- (NSString *)pathForUnlocalizedResource:(NSString *)fileName {
    return [resourcesFilePath stringByAppendingPathComponent:fileName];
}

- (NSString *)pathForLocalizedResource:(NSString *)fileName {
    return [resourcesFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"languages/%@/%@", AGLOCALIZATION.localization, fileName] ];
}

- (NSString *)pathForResource:(NSString *)fileName {
    NSString *filePath = [self pathForLocalizedResource:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }

    return [self pathForUnlocalizedResource:fileName];
}

@end
