#import "NSURLSession+HTTP.h"
#import <objc/runtime.h>

@implementation NSURLSession (HTTP)

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request progress:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))progress completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler {

    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request];
    [self setValue:self forKey:@"delegate"];

    return downloadTask;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    [self setNilValueForKey:@"delegate"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
}

@end
