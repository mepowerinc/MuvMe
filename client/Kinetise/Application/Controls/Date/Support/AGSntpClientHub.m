#import "AGSntpClientHub.h"

@interface AGSntpClientHub (){
    NSObject *mutex;
}
@property(nonatomic, retain) NSDate *lastSynchronization;
@property(nonatomic, assign) NSTimeInterval clockOffset;
@end

@implementation AGSntpClientHub

SINGLETON_IMPLEMENTATION(AGSntpClientHub)

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.lastSynchronization = nil;
    [mutex release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.lastSynchronization = nil;
    self.synchronizationInterval = 24 * 60 * 60;
    mutex = [[NSObject alloc] init];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(systemTimeChanged) name:NSSystemClockDidChangeNotification object:nil];

    return self;
}

- (void)systemTimeChanged {
    self.lastSynchronization = nil;
}

- (void)setSynchronizedClockOffset:(NSTimeInterval)clockOffset {
    @synchronized(mutex){
        self.clockOffset = clockOffset;
        self.lastSynchronization = [NSDate date];
    }
}

- (BOOL)shouldSynchronize {
    @synchronized(mutex){
        if (!self.lastSynchronization) return YES;

        NSDate *now = [NSDate date];
        return ([now timeIntervalSinceDate:self.lastSynchronization] > self.synchronizationInterval);
    }
}

- (BOOL)synchronized {
    NSDate *now = [NSDate date];

    @synchronized(mutex){
        return (self.lastSynchronization && [now timeIntervalSinceDate:self.lastSynchronization] <= self.synchronizationInterval);
    }
}

@end
