#import <Foundation/Foundation.h>

@interface NSURLSession (HTTP)

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request progress:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))progress completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler;

@end