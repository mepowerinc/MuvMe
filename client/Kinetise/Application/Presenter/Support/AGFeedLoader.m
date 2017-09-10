#import "AGFeedLoader.h"
#import "AGFeedRequest.h"
#import "AGServicesManager.h"
#import "AGApplication.h"
#import "AGApplication+Control.h"
#import "AGActionManager.h"
#import "AGFeedAsset.h"
#import "NSString+URL.h"
#import "NSString+UriEncoding.h"
#import "AGLayoutManager.h"
#import "AGOverlayDesc+Layout.h"
#import "AGScreenDesc+Layout.h"
#import "DescriptorsHeader.h"
#import "NSObject+Nil.h"
#import "AGDesc+Layout.h"
#import <JSONQuery/NSData+JQ.h>

@interface AGFeedLoader () <AGAssetDelegate>{
    NSMutableArray *requests;
    NSArray *feeds;
}
@property(nonatomic, retain) NSArray *feeds;
@end

@implementation AGFeedLoader

@synthesize feeds;

- (void)dealloc {
    [requests release];
    self.feeds = nil;
    [super dealloc];
}

- (id)initWithFeeds:(NSArray *)feeds_ {
    self = [super init];

    requests = [[NSMutableArray alloc] init];
    self.feeds = feeds_;

    return self;
}

#pragma mark - Lifecycle

- (void)cancellAllRequests {
    [requests removeAllObjects];
}

- (void)loadFeeds {
    [self cancellAllRequests];

    for (AGControlDesc<AGFeedClientProtocol> *feedClient in feeds) {
        AGFeedRequest *request = [[AGFeedRequest alloc] initWithFeedClient:feedClient];
        [requests addObject:request];
        [self startRequest:request];
        [request release];
    }
}

- (void)reloadFeeds {
    [self cancellAllRequests];

    // load feeds
    for (AGControlDesc<AGFeedClientProtocol> *feedClient in feeds) {
        AGFeedRequest *request = [[AGFeedRequest alloc] initWithFeedClient:feedClient];
        request.isReload = YES;
        [requests addObject:request];
        [self startRequest:request];
        [request release];
    }
}

- (void)loadNextFeedPage:(AGControlDesc<AGFeedClientProtocol> *)feedClient {
    // feed
    AGFeed *feed = feedClient.feed;

    // items to show
    NSInteger itemsToShow = feed.dataSource.items.count-(feed.showItems+feed.showItems*feed.pageIndex);

    if (feedClient.feed.dataSource) {
        // next page index
        ++feedClient.feed.pageIndex;

        // request
        AGFeedRequest *request = [self findRequestForFeedClient:feedClient];
        request.isReload = NO;
        request.isLoadMore = YES;

        // pagination
        if (feed.paginationType != feedPaginantionNone) {
            if (feed.showItems == itemsToShow) {
                // reload controls
                [self reloadFeedControlAndDescriptor:feedClient withDataSource:feedClient.feed.dataSource];
            } else {
                // request
                [self startRequest:request];
            }
        } else {
            // reload controls
            [self reloadFeedControlAndDescriptor:feedClient withDataSource:feedClient.feed.dataSource];
        }
    }
}

#pragma mark - Request

- (void)startRequest:(AGFeedRequest *)request {
    // feed client
    AGControlDesc<AGFeedClientProtocol> *feedClient = request.feedClient;

    // feed
    AGFeed *feed = feedClient.feed;

    // uri
    feed.fullPath = [feedClient fullPath:feed.src.value ];
    NSString *uri = [feed.fullPath uriString];

    // pagination url
    if (request.isLoadMore && feed.paginationType == feedPaginationURL && [feed.dataSource.pagination hasPrefix:@"http"]) {
        feed.fullPath = [feedClient fullPath:feed.dataSource.pagination ];
        uri = [feed.fullPath uriString];
    }

    // http query params
    NSMutableDictionary *httpQueryParams = [feed.httpQueryParams execute];

    // http
    if ([uri hasPrefix:@"http"]) {
        // pagination token
        if (request.isLoadMore && feed.paginationType == feedPaginationToken && isNotEmpty(feed.dataSource.pagination) && isNotEmpty(feed.paginationHtthParam) ) {
            httpQueryParams[feed.paginationHtthParam] = feed.dataSource.pagination;
        }

        // url
        NSURL *url = nil;
        NSString *uri_ = [uri stringByAppendingURLQuery:[NSString URLQueryWithParameters:httpQueryParams] ];
        url = [NSURL URLWithString:uri_];

        // mark url as expired
        if (request.isReload) {
            [[AGServicesManager sharedInstance] markURL:url asExpired:YES];
        }
    }

    // http body
    NSData *httpBody = nil;
    if (![feed.httpMethod isEqualToString:@"GET"]) {
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        json[@"params"] = [feed.httpBodyParams execute];
        httpBody = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];

        if (isNotEmpty(feed.requestBodyTransform) ) {
            NSData *transformedJsonData = [httpBody jq:feed.requestBodyTransform];
            if (transformedJsonData) {
                httpBody = transformedJsonData;
            }
        }
    }

    // asset
    AGFeedAsset *source = [[AGFeedAsset alloc] initWithUri:uri ];
    source.httpMethod = feed.httpMethod;
    if (!request.isLoadMore || feed.paginationType != feedPaginationURL || ![feed.dataSource.pagination hasPrefix:@"http"]) {
        source.httpQueryParams = httpQueryParams;
    }
    source.httpHeaderParams = [feed.httpHeaderParams execute];
    source.httpBody = httpBody;
    source.cachePolicy = feed.cachePolicy;
    source.cacheInterval = feed.cacheInterval;
    source.delegate = self;
    source.feed = feed;
    request.source = source;
    [source execute];
    [source release];
}

#pragma mark - Reload

- (void)reloadFeedControlAndDescriptor:(AGControlDesc<AGFeedClientProtocol> *)feedClient withDataSource:(AGDSFeed *)dataSource {
    AGFeedRequest *request = [self findRequestForFeedClient:feedClient];
    if (!request) return;

    // feed
    AGFeed *feed = feedClient.feed;

    // data source
    feed.dataSource = dataSource;

    // max items
    NSInteger maxShowItems = MIN(feed.showItems+feed.showItems*feed.pageIndex, dataSource.items.count);

    // load more
    BOOL hasLoadMore = NO;
    if (dataSource.items.count > maxShowItems) {
        hasLoadMore = YES;
    }
    if (feed.paginationType != feedPaginantionNone && isNotEmpty(dataSource.pagination) ) {
        hasLoadMore = YES;
    }

    // remove load more control
    // if first load no controls, if load more - last control is always loadMoreControl
    [feedClient removeLastFeedControl];

    // add new items to feed client
    AGDSFeed *feedDataSource = feed.dataSource;
    NSUInteger startIndex = feedClient.feedControls.count;
    NSUInteger endIndex = maxShowItems;

    for (NSUInteger i = startIndex; i < endIndex; ++i) {
        AGDSFeedItem *feedItem = feedDataSource.items[i];

        if (feedItem.itemTemplateIndex != NSNotFound) {
            AGFeedItemTemplate *itemTemplate = feed.itemTemplates[feedItem.itemTemplateIndex];
            AGControlDesc *controlDesc = [itemTemplate.controlDesc copy];
            controlDesc.itemIndex = i;

            [feedClient addFeedControl:controlDesc];

            // execute variables
            [controlDesc executeVariables];
            
            // update
            [controlDesc update];

            [controlDesc release];
        }
    }

    // no data
    if (dataSource.items.count == 0) {
        if (feedClient.feed.itemTemplateNoData) {
            AGControlDesc *controlDesc = [feedClient.feed.itemTemplateNoData copy];
            [feedClient addFeedControl:controlDesc ];

            // execute variables
            [controlDesc executeVariables];
            
            // update
            [controlDesc update];

            [controlDesc release];
        }
    }

    // load more
    if (feed.itemTemplateLoadMore && hasLoadMore) {
        AGControlDesc *controlDesc = [feed.itemTemplateLoadMore copy];
        [feedClient addFeedControl:controlDesc];

        // execute variables
        [controlDesc executeVariables];
        
        // update
        [controlDesc update];

        [controlDesc release];
    }

    // layout descriptor
    AGDesc *parentDesc = [self findViewForCalculate:feedClient];
    [AGLAYOUTMANAGER layout:parentDesc];

    // mark expired links
    if (request.isReload) {
        NSMutableArray *urls = [[NSMutableArray alloc] init];

        NSArray *feedControls = [feedClient feedControls];
        for (int i = 0; i < feedControls.count; ++i) {
            if (i < [feedClient feedControls].count) {
                AGControlDesc *controlDesc = feedControls[i];
                [self findUrls:controlDesc withArray:urls];
            }
        }

        for (NSString *uri in urls) {
            uri = [[feed fullPath:uri] uriString];
            if ([uri hasPrefix:@"http"]) {
                NSURL *url = [NSURL URLWithString:uri];
                [[AGServicesManager sharedInstance] markURL:url asExpired:YES];
            }
        }

        [urls release];
    }

    // reload control
    {
        // control
        AGControl<AGFeedProtocol> *control = (AGControl<AGFeedProtocol> *)[AGAPPLICATION getControl:((AGControlDesc *)feedClient).identifier ];

        // reload data
        [control reloadData];

        // layout views
        AGDesc *parentDesc = [self findViewForCalculate:(AGControlDesc *)control.descriptor];
        AGView *parent = [AGAPPLICATION getViewWithDesc:parentDesc];
        [parent setNeedsLayout];
    }
}

- (void)reloadFeedControlAndDescriptor:(AGControlDesc *)controlDesc {
    // reload descriptor
    {
        // execute variables
        [controlDesc executeVariables];
        
        // update
        [controlDesc update];

        // layout descriptors
        AGDesc *parentDesc = [self findViewForCalculate:controlDesc];
        [AGLAYOUTMANAGER layout:parentDesc];
    }

    // reload control
    {
        // control
        AGControl<AGFeedProtocol> *control = (AGControl<AGFeedProtocol> *)[AGAPPLICATION getControl:controlDesc.identifier];

        // reload data
        [control reloadData];

        // layout views
        AGDesc *parentDesc = [self findViewForCalculate:(AGControlDesc *)control.descriptor];
        AGView *parent = [AGAPPLICATION getViewWithDesc:parentDesc];
        [parent setNeedsLayout];
    }
}

#pragma mark - Find

- (AGFeedRequest *)findRequestForFeedClient:(AGControlDesc<AGFeedClientProtocol> *)feedClient {
    for (AGFeedRequest *request in requests) {
        if (request.feedClient == feedClient) {
            return request;
        }
    }
    return nil;
}

- (AGFeedRequest *)findRequestForSource:(AGAsset *)source {
    for (AGFeedRequest *request in requests) {
        if (request.source == source) {
            return request;
        }
    }
    return nil;
}

- (AGDesc *)findViewForCalculate:(AGControlDesc *)controlDesc {
    if (controlDesc.width.units != unitMin && controlDesc.height.units != unitMin) {
        return controlDesc;
    } else if (controlDesc.parent) {
        return [self findViewForCalculate:controlDesc.parent];
    } else {
        if (controlDesc.section) {
            return controlDesc.section;
        } else {
            return [AGAPPLICATION getControlPresenterDesc:controlDesc];
        }
    }
}

- (void)findUrls:(AGControlDesc *)controlDesc withArray:(NSMutableArray *)array {
    if ([controlDesc isKindOfClass:[AGButtonDesc class]]) {
        AGButtonDesc *buttonDesc = (AGButtonDesc *)controlDesc;
        if (isNotNil(buttonDesc.activeSrc.value) ) {
            [array addObject:buttonDesc.activeSrc.value];
        }
    }
    if ([controlDesc isKindOfClass:[AGCompoundButtonDesc class]]) {
        AGCompoundButtonDesc *buttonDesc = (AGCompoundButtonDesc *)controlDesc;
        if (isNotNil(buttonDesc.activeSrc.value) ) {
            [array addObject:buttonDesc.activeSrc.value];
        }
        if (isNotNil(buttonDesc.src.value) ) {
            [array addObject:buttonDesc.src.value];
        }
    }
    if ([controlDesc isKindOfClass:[AGImageDesc class]]) {
        AGImageDesc *imageDesc = (AGImageDesc *)controlDesc;
        if (isNotNil(imageDesc.src.value) ) {
            [array addObject:imageDesc.src.value];
        }
    }
    if ([controlDesc isKindOfClass:[AGControlDesc class]]) {
        if (isNotNil(controlDesc.background.value) ) {
            [array addObject:controlDesc.background.value];
        }
    }
    if ([controlDesc isKindOfClass:[AGContainerDesc class]]) {
        AGContainerDesc *containerDesc = (AGContainerDesc *)controlDesc;
        for (AGControlDesc *child in containerDesc.children) {
            [self findUrls:child withArray:array];
        }
    }
}

#pragma mark - AGAssetDelegate

- (void)assetWillLoadSilent:(AGFeedAsset *)asset {
    asset.httpQueryParams = [asset.feed.httpQueryParams execute];
    asset.httpHeaderParams = [asset.feed.httpHeaderParams execute];
}

- (void)assetWillLoad:(AGFeedAsset *)asset {
    AGFeedRequest *request = [self findRequestForSource:asset];
    AGControlDesc<AGFeedClientProtocol> *feedClient = request.feedClient;

    if (!request.isLoadMore) {
        // clear feed
        [feedClient removeFeedControls];

        // loading indicator
        if (asset.assetType == assetHttp && !asset.isCachedData && !asset.isSilentRequest) {
            if (feedClient.feed.itemTemplateLoading) {
                AGControlDesc *controlDesc = [feedClient.feed.itemTemplateLoading copy];
                [feedClient addFeedControl:controlDesc ];
                [controlDesc release];
            }
        }

        // reload feed client
        [self reloadFeedControlAndDescriptor:(AGControlDesc *)feedClient];
    }
}

- (void)asset:(AGFeedAsset *)asset didLoad:(AGDSFeed *)dataSource {
    AGFeedRequest *request = [self findRequestForSource:asset];
    AGControlDesc<AGFeedClientProtocol> *feedClient = request.feedClient;
    AGFeed *feed = asset.feed;

    feed.hasSilentResponse = asset.isSilentRequest;

    if (request.isLoadMore) {
        if (asset.isSilentRequest) {
            request.isReload = NO;
        } else {
            // add new items
            NSMutableArray *items = [NSMutableArray arrayWithArray:feed.dataSource.items ];
            [items addObjectsFromArray:dataSource.items ];
            dataSource.items = items;
        }
    } else {
        if (asset.isSilentRequest) {
            // clear feed
            [feedClient removeFeedControls];

            // no reload
            request.isReload = NO;
        }
    }

    // reload controls
    [self reloadFeedControlAndDescriptor:feedClient withDataSource:dataSource];
}

- (void)asset:(AGFeedAsset *)asset didFail:(NSError *)error {
    AGFeedRequest *request = [self findRequestForSource:asset];
    AGControlDesc<AGFeedClientProtocol> *feedClient = request.feedClient;

    if (request.isLoadMore) {
        if (asset.isSilentRequest) {
            request.isReload = NO;
        }
    } else {
        // remove controls
        [feedClient removeFeedControls];

        // error indicator
        if (feedClient.feed.itemTemplateError) {
            AGControlDesc *controlDesc = [feedClient.feed.itemTemplateError copy];
            [feedClient addFeedControl:controlDesc ];
            [controlDesc release];
        }

        // silent request
        if (asset.isSilentRequest) {
            request.isReload = NO;
        }
    }

    // reload feed client
    [self reloadFeedControlAndDescriptor:(AGControlDesc *)feedClient];
}

@end
