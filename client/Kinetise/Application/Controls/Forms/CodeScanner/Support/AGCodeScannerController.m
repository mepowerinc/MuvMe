#import "AGCodeScannerController.h"
#import "AGCodeScannerView.h"

@interface AGCodeScannerController () <AVCaptureMetadataOutputObjectsDelegate>{
    UIView *borderView;
    NSArray *metadataObjectTypes;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    UINavigationBar *navigationBar;
    BOOL processing;
}
@property(nonatomic, retain) NSArray *metadataObjectTypes;
@property(nonatomic, copy) void (^completionBlock) (AGCodeScannerController *scanner, UIImage *image, NSString *);
@end

@implementation AGCodeScannerController

@synthesize title;
@synthesize metadataObjectTypes;
@synthesize completionBlock;
@synthesize isRunning;

- (void)dealloc {
    [session release];
    self.metadataObjectTypes = nil;
    self.completionBlock = nil;
    self.title = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // background
    self.view.backgroundColor = [UIColor blackColor];
    
    // navigation bar
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:title] autorelease];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    // device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device) {
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        AVCaptureMetadataOutput *metadataOutput = [[[AVCaptureMetadataOutput alloc] init] autorelease];
        
        // session
        session = [[AVCaptureSession alloc] init];
        [session addOutput:metadataOutput];
        [session addInput:deviceInput];
        
        if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            session.sessionPreset = AVCaptureSessionPreset1280x720;
        }
        
        // metadata
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [metadataOutput setMetadataObjectTypes:metadataObjectTypes];
        
        // still image output
        stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [session addOutput:stillImageOutput];
        [stillImageOutput release];
        
        // layer
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        
        // start
        [self startScanning];
    }
    
    // border
    borderView = [[AGCodeScannerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:borderView];
    [borderView release];
}

- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes_ andCompletionBlock:(void (^)(AGCodeScannerController *scanner, UIImage *image, NSString *resultString))completionBlock_ {
    self = [super init];
    
    // title
    self.title = @"Scanner";
    
    // metadata
    self.metadataObjectTypes = metadataObjectTypes_;
    
    // completion block
    self.completionBlock = completionBlock_;
    
    return self;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // navigation bar
    CGFloat satusBarHeight = [UIApplication sharedApplication].statusBarHidden ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
    navigationBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44+satusBarHeight);
    
    // border
    CGFloat side = self.view.bounds.size.width < self.view.bounds.size.height ? self.view.bounds.size.width : self.view.bounds.size.height;
    borderView.frame = CGRectMake(0, 0, side*0.75f, side*0.75f);
    borderView.center = CGPointMake(self.view.bounds.size.width*0.5f, satusBarHeight+44+(self.view.bounds.size.height-satusBarHeight-44)*0.5f);
    
    // preview
    previewLayer.frame = self.view.bounds;
}

#pragma mark - Lifecycle

- (void)setTitle:(NSString *)title_ {
    if ([title isEqualToString:title_]) return;
    
    [title release];
    title = [title_ copy];
    
    self.navigationItem.title = title_;
}

- (void)onCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

+ (BOOL)isAvailable {
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (!captureDevice) {
            return NO;
        }
        
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        
        return YES;
    }
}

- (void)startScanning {
    if (![session isRunning]) {
        [session startRunning];
    }
}

- (void)stopScanning {
    if ([session isRunning]) {
        [session stopRunning];
    }
}

- (BOOL)isRunning {
    return session.running;
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - AVCaptureMetadataOutputObjects Delegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (processing) return;
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataObject *metadataObject = [metadataObjects firstObject];
        
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]] && [metadataObjectTypes containsObject:metadataObject.type]) {
            AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
            NSString *scannedResult = [codeObject stringValue];
            
            AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
            [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            [stillImageConnection setVideoScaleAndCropFactor:1.0f];
            [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey]];
            stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG, AVVideoQualityKey:@1};
            
            processing = YES;
            [stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){
                __block UIImage *image = nil;
                
                if (!error) {
                    NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    image = [UIImage imageWithData:jpegData];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // sound
                    //AudioServicesPlaySystemSound(1108);
                    
                    // completion block
                    if (completionBlock) {
                        completionBlock(self, image, scannedResult);
                    }
                    
                    // processing
                    processing = NO;
                });
            }];
        }
    }
}

@end
