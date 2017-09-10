#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AGCodeScannerController : UIViewController

@property(nonatomic, readonly) BOOL isRunning;
@property(nonatomic, copy) NSString *title;

+ (BOOL)isAvailable;
- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes andCompletionBlock:(void (^)(AGCodeScannerController *scanner, UIImage *image, NSString *resultString))completionBlock;
- (void)startScanning;
- (void)stopScanning;

@end
