#import <JavaScriptCore/JavaScriptCore.h>
#import "AGFeedAsset.h"
#import "NSString+URL.h"
#import "AGActionManager.h"
#import "AGFileManager.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"
#import "AGApplication+Authentication.h"
#import "AGApplication+Popup.h"
#import "AGAlterApiResponse.h"
#import "AGLocalizationManager.h"
#import "AGServicesManager.h"
#import "AGAssetsManager.h"
#import "AGLocalStorage.h"

@implementation AGFeedAsset
@synthesize feed;

#pragma mark - Initialization

- (void)dealloc {
    self.feed = nil;
    [super dealloc];
}

- (id)initWithUri:(NSString *)uri_ {
    self = [super initWithUri:uri_];

    // data type
    assetDataType = assetFeedData;

    return self;
}

#pragma mark - Execution

- (void)execute {
    [super execute];

    // asset
    if (assetType == assetFile) {
        NSString *fileNameWithExtension = [[uri stringByDeletingURLQuery] substringFromIndex:[@"assets://" length] ];
        NSString *filePath = [AGFILEMANAGER pathForResource:fileNameWithExtension];

        NSData *feedData = [NSData dataWithContentsOfFile:filePath];
        [self processData:feedData asynchronous:NO];
    }

    // context
    if (assetType == assetContext) {
        AGFeed *contextFeed = AGAPPLICATION.currentContext;
        AGDSFeed *contextFeedDs = contextFeed.dataSource;

        if (contextFeedDs) {
            [delegate asset:self didLoad:contextFeedDs];
        } else {
            [delegate asset:self didFail:nil];
        }
    }

    // local
    if (assetType == assetLocalStorage) {
        NSString *URLQuery = [NSString URLQueryWithParameters:httpQueryParams];
        NSURL *url = [NSURL URLWithString:[uri stringByAppendingURLQuery:URLQuery] ];

        // url components
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSString *tableName = urlComponents.host;
        NSURLQueryItem *filterQuery = nil;
        NSURLQueryItem *sortQuery = nil;
        NSURLQueryItem *pageSizeQuery = nil;

        // arguments
        JSValue *filterFunction = nil;
        NSString *sort = nil;
        BOOL sortDescending = NO;
        NSUInteger limit = 0;

        // query
        for (NSURLQueryItem *query in urlComponents.queryItems) {
            if ([query.name isEqualToString:@"filter"] && query.value.length > 0) {
                filterQuery = query;
            } else if ([query.name isEqualToString:@"sort"] && query.value.length > 0) {
                sortQuery = query;
            } else if ([query.name isEqualToString:@"pageSize"] && query.value.length > 0) {
                pageSizeQuery = query;
            }
        }

        // filter
        if (filterQuery) {
            // context
            JSContext *context = [[[JSContext alloc] init] autorelease];
            context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
                NSLog(@"%@\n", exception);
            };

            // script
            NSString *script = [NSString stringWithFormat:@"function filter(item, input){%@}", filterQuery.value];
            [context evaluateScript:script];

            // filter function
            filterFunction = [context objectForKeyedSubscript:@"filter"];
        }

        // sort
        if (sortQuery) {
            sortDescending = [sortQuery.value hasPrefix:@"-"];
            sort = sortDescending ? [sortQuery.value substringFromIndex:1] : sortQuery.value;
        }

        // page size
        if (pageSizeQuery) {
            limit = [pageSizeQuery.value integerValue];
        }

        [AGLOCALSTORAGE query:tableName values:httpHeaderParams filter:^BOOL (NSDictionary *item, NSDictionary *input) {
            if (filterQuery) {
                return [filterFunction callWithArguments:@[item, input] ].toBool;
            }

            return YES;
        } sort:sort ascending:!sortDescending limit:limit completion:^(NSArray *items) {
            [self processData:(NSData *)items asynchronous:NO];
        }];
    }
}

- (void)cancel {
    [super cancel];
    [feedOperation clearDelegatesAndCancel];
    feedOperation = nil;
}

#pragma mark - Response

- (void)processData:(NSData *)data asynchronous:(BOOL)asynchronous {
    if (feedOperation) {
        [feedOperation clearDelegatesAndCancel];
    }

    feedOperation = [[AGFeedParseOperation alloc] initWithFeed:feed andData:data];
    feedOperation.delegate = self;

    if (asynchronous) {
        [[AGAssetsManager sharedInstance].feedProcessingQueue addOperation:feedOperation];
        [feedOperation release];
    } else {
        [feedOperation autorelease];
        [feedOperation startSynchronous];
    }
}

- (void)processCachedResponse:(NSCachedURLResponse *)cachedResponse {
    [super processCachedResponse:cachedResponse];

    // feed date
    NSHTTPURLResponse *HTTPCachedResponse = (NSHTTPURLResponse *)cachedResponse.response;
    feed.dateTS = [[AGServicesManager sharedInstance] HTTPHeaderDate:HTTPCachedResponse.allHeaderFields ];
}

- (void)processHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data andError:(NSError *)error {
    // cancelled
    if (error.code == NSURLErrorCancelled) {
        return;
    }

    // feed
    if (response.statusCode >= 200 && response.statusCode < 400) {
        // date form response headers
        if (!isCachedData) {
            feed.dateTS = [[AGServicesManager sharedInstance] HTTPHeaderDate:response.allHeaderFields ];
        }
    }

    // process response
    [super processHTTPResponse:response withData:data andError:error];

    // process alter api response
    if (!isSilentRequest) {
        [self processAlterApiResponse:response withData:data andError:error];
    }
}

- (void)processAlterApiResponse:(NSHTTPURLResponse *)response withData:(NSData *)data andError:(NSError *)error {
    if (response.statusCode) {
        // alter api response
        AGAlterApiResponse *responseObject = nil;

        // parse xml or json
        if (response.statusCode < 200 || response.statusCode >= 400) {
            NSError *parserError = nil;

            if (feed.format == feedFormatJSON) {
                if (data.length == 0) {
                    data = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
                }

                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parserError];
                if (json) {
                    responseObject = [[[AGAlterApiResponse alloc] initWithJSON:json] autorelease];
                }
            } else if (feed.format == feedFormatXML) {
                if (data.length == 0) {
                    data = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><response/>" dataUsingEncoding:NSUTF8StringEncoding];
                }

                GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:data options:0 error:&parserError];
                if (xmlDocument) {
                    responseObject = [[[AGAlterApiResponse alloc] initWithXML:xmlDocument.rootElement] autorelease];
                }
                [xmlDocument release];
            }

            if (parserError) {
                NSLog(@"Error: %@", parserError.localizedDescription);
            }

            if (responseObject.isAlterApiResponse) {
                // messages
                if (responseObject.messages) {
                    for (NSString *message in responseObject.messages) {
                        if (response.statusCode == 403) {
                            [AGAPPLICATION showErrorPopup:message];
                        } else {
                            [AGAPPLICATION.toast makeToast:message];
                        }
                    }
                } else {
                    if (responseObject.messageDescription) {
                        if (response.statusCode == 403) {
                            if (responseObject.messageTitle) {
                                [AGAPPLICATION showAlert:responseObject.messageTitle message:responseObject.messageDescription];
                            } else {
                                [AGAPPLICATION showErrorPopup:responseObject.messageDescription];
                            }
                        } else {
                            [AGAPPLICATION.toast makeToast:responseObject.messageDescription];
                        }
                    }
                }

                // invalid session
                if (response.statusCode == 403) {
                    if (responseObject.messages.count == 0 && !responseObject.messageTitle && !responseObject.messageDescription) {
                        [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_INVALID_SESSION"] ];
                    }
                    [AGAPPLICATION logout];
                } else if (response.statusCode == 400) {
                    if (responseObject.messages.count == 0 && !responseObject.messageTitle && !responseObject.messageDescription) {
                        [self showHttpErrorWithStatusCode:response.statusCode];
                    }
                }
            } else {
                if (response.statusCode == 401) {
                    [AGAPPLICATION showErrorPopup:[AGLOCALIZATION localizedString:@"ERROR_INVALID_SESSION"] ];
                    [AGAPPLICATION logout];
                } else {
                    [self showHttpErrorWithStatusCode:response.statusCode];
                }
            }
        }
    } else {
        // error toast
        if (error.code == NSURLErrorTimedOut) {
            [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"ERROR_CONNECTION_TIMEOUT"] ];
        } else if (error.code == NSURLErrorCannotFindHost) {
            NSString *host = [uri URLHost];
            NSString *message = [NSString stringWithFormat:@"%@%@", [AGLOCALIZATION localizedString:@"ERROR_COULD_NOT_RESOLVE_DOMAIN_NAME"], host];
            [AGAPPLICATION.toast makeToast:message ];
        } else {
            [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedString:@"ERROR_CONNECTION"] ];
        }
    }
}

- (void)showHttpErrorWithStatusCode:(NSInteger)responseStatusCode {
    [AGAPPLICATION.toast makeToast:[AGLOCALIZATION localizedHttpError:responseStatusCode] ];
}

#pragma mark - AGFeedParseOperationDelegate

- (void)feed:(AGFeedParseOperation *)operation didLoad:(AGDSFeed *)feedDataSource {
    // delegate
    [delegate asset:self didLoad:feedDataSource];

    // operation
    feedOperation = nil;

    // finish operation
    [self finishProcessingData];
}

- (void)feed:(AGFeedParseOperation *)operation didFail:(NSError *)error {
    // delegate
    [delegate asset:self didFail:error];

    // operation
    feedOperation = nil;

    // finish operation
    [self finishProcessingData];
}

@end
