#import "AGSntpClient.h"
#import <CocoaAsyncSocket/AsyncUdpSocket.h>

typedef signed char byte;

// static const int REFERENCE_TIME_OFFSET = 16;
static const int ORIGINATE_TIME_OFFSET = 24;
static const int RECEIVE_TIME_OFFSET = 32;
static const int TRANSMIT_TIME_OFFSET = 40;
static const int NTP_PACKET_SIZE = 48;

static const int NTP_PORT = 123;
static const int NTP_MODE_CLIENT = 3;
static const int NTP_VERSION = 3;

// number of seconds between Jan 1, 1900 and Jan 1, 1970
// 70 years plus 17 leap days
static const long long OFFSET_1900_TO_1970 = ((365LL * 70LL) + 17LL) * 24LL * 60LL * 60LL;

// supporting functions
void writeTime(NSTimeInterval time, byte *buffer, int offset);
long long read32(byte *buffer, int offset);
NSTimeInterval readTime(byte *buffer, int offset);

@interface AGSntpClient ()<AsyncUdpSocketDelegate>{
    int requestsCounter;
}
@end

@implementation AGSntpClient

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    self.timeout = 30;
    requestsCounter = 0;

    return self;
}

- (void)requestTime:(NSString *)host {
    if (![self.hub shouldSynchronize]) {
        NSDate *now = [NSDate date];
        now = [NSDate dateWithTimeInterval:self.hub.clockOffset sinceDate:now];

        if (self.delegate && [self.delegate respondsToSelector:@selector(sntpClient:receivedNtpTime:)]) {
            [self.delegate sntpClient:self receivedNtpTime:now];
        }
        return;
    }

    NSError *error;
    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc] initWithDelegate:self];

    error = nil;
    BOOL result = [socket connectToHost:host onPort:NTP_PORT error:&error];
    if (error || !result)
        goto error_handling;

    byte buffer[NTP_PACKET_SIZE];
    memset(buffer, 0, NTP_PACKET_SIZE); //clear buffer

    // set mode = 3 (client) and version = 3
    // mode is in low 3 bits of first byte
    // version is in bits 3-5 of first byte
    buffer[0] = NTP_MODE_CLIENT | (NTP_VERSION << 3);

    // get current time and write it to the request packet
    NSTimeInterval requestTime = [[NSDate date] timeIntervalSince1970];
    writeTime(requestTime, buffer, TRANSMIT_TIME_OFFSET);

    NSData *requestData = [NSData dataWithBytes:buffer length:NTP_PACKET_SIZE];
    result = [socket sendData:requestData withTimeout:self.timeout tag:0];
    if (!result) {
        error = [NSError errorWithDomain:@"SNTP" code:100 userInfo:@{@"message": @"cound not send request"}];
        goto error_handling;
    }

    ++requestsCounter;

    return;

error_handling:
    if (![socket isClosed])
        [socket close];

    [socket release];
    [self notifyError:error];
}

- (BOOL)synchronized {
    return self.hub.synchronized;
}

- (NSDate *)synchronizedTime {
    return [NSDate dateWithTimeInterval:self.hub.clockOffset sinceDate:[NSDate date]];
}

- (BOOL)isSynchronizing {
    return requestsCounter > 0;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    [sock receiveWithTimeout:self.timeout tag:tag];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    [self finish:sock];
    [self notifyError:error];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port {
    NSTimeInterval responseTime = [[NSDate date] timeIntervalSince1970];

    byte buffer[NTP_PACKET_SIZE];
    memset(buffer, 0, NTP_PACKET_SIZE);

    [data getBytes:buffer length:NTP_PACKET_SIZE];

    NSTimeInterval originateTime = readTime(buffer, ORIGINATE_TIME_OFFSET);
    NSTimeInterval receiveTime = readTime(buffer, RECEIVE_TIME_OFFSET);
    NSTimeInterval transmitTime = readTime(buffer, TRANSMIT_TIME_OFFSET);

    NSTimeInterval clockOffset = ((receiveTime - originateTime) + (transmitTime - responseTime))/2;

    NSDate *resultTime = [NSDate dateWithTimeIntervalSince1970:(responseTime + clockOffset)];

    [self.hub setSynchronizedClockOffset:clockOffset];

    if (self.delegate && [self.delegate respondsToSelector:@selector(sntpClient:receivedNtpTime:)]) {
        [self.delegate sntpClient:self receivedNtpTime:resultTime];
    }

    [self finish:sock];

    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    [self finish:sock];
    [self notifyError:error];
}

- (void)finish:(AsyncUdpSocket *)sock {
    --requestsCounter;
    [sock close];
    [sock release];
}

- (void)notifyError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sntpClient:failedWithError:)]) {
        [self.delegate sntpClient:self failedWithError:error];
    }
}

- (AGSntpClientHub *)hub {
    return [AGSntpClientHub sharedInstance];
}

@end

// supporting functions
void writeTime(NSTimeInterval time, byte *buffer, int offset) {
    long long seconds = (long long)time;
    long long milliseconds = (time - (double)seconds) * 1000L;
    seconds += OFFSET_1900_TO_1970;

    // write seconds in big endian format
    buffer[offset++] = (byte)(seconds >> 24);
    buffer[offset++] = (byte)(seconds >> 16);
    buffer[offset++] = (byte)(seconds >> 8);
    buffer[offset++] = (byte)(seconds >> 0);

    long long fraction = milliseconds * 0x100000000L / 1000L;
    // write fraction in big endian format
    buffer[offset++] = (byte)(fraction >> 24);
    buffer[offset++] = (byte)(fraction >> 16);
    buffer[offset++] = (byte)(fraction >> 8);
    // low order bits should be random data
    buffer[offset++] = (byte)(arc4random_uniform(256));
}

long long read32(byte *buffer, int offset) {
    byte b0 = buffer[offset];
    byte b1 = buffer[offset+1];
    byte b2 = buffer[offset+2];
    byte b3 = buffer[offset+3];

    // convert signed bytes to unsigned values
    int i0 = ((b0 & 0x80) == 0x80 ? (b0 & 0x7F) + 0x80 : b0);
    int i1 = ((b1 & 0x80) == 0x80 ? (b1 & 0x7F) + 0x80 : b1);
    int i2 = ((b2 & 0x80) == 0x80 ? (b2 & 0x7F) + 0x80 : b2);
    int i3 = ((b3 & 0x80) == 0x80 ? (b3 & 0x7F) + 0x80 : b3);

    return ((long long)i0 << 24) + ((long long)i1 << 16) + ((long long)i2 << 8) + (long long)i3;
}

NSTimeInterval readTime(byte *buffer, int offset) {
    long long seconds = read32(buffer, offset);
    long long fraction = read32(buffer, offset + 4);

    long long time = ((seconds - OFFSET_1900_TO_1970) * 1000LL) + ((fraction * 1000LL) / 0x100000000LL);
    NSTimeInterval nstime = time / 1000.0;
    return nstime;
}

