#import "AGFeed.h"
#import "AGActionManager.h"
#import "AGApplication.h"
#import "NSString+URL.h"

@implementation AGFeed

@synthesize namespaces;
@synthesize usingFields;
@synthesize itemTemplates;
@synthesize itemPath;
@synthesize src;
@synthesize httpQueryParams;
@synthesize httpHeaderParams;
@synthesize httpBodyParams;
@synthesize requestBodyTransform;
@synthesize httpMethod;
@synthesize cachePolicy;
@synthesize cacheInterval;
@synthesize showItems;
@synthesize format;
@synthesize dataSource;
@synthesize itemTemplateNoData;
@synthesize itemTemplateError;
@synthesize itemTemplateLoading;
@synthesize itemTemplateLoadMore;
@synthesize pageIndex;
@synthesize sortField;
@synthesize sortOrder;
@synthesize dateTS;
@synthesize itemIndex;
@synthesize csvSeparator;
@synthesize csvHeader;
@synthesize guidUsingField;
@synthesize formId;
@synthesize fullPath;
@synthesize paginationType;
@synthesize paginationHtthParam;
@synthesize paginationPath;
@synthesize hasSilentResponse;

#pragma mark - Initialization

- (void)dealloc {
    [namespaces release];
    [usingFields release];
    [itemTemplates release];
    self.httpQueryParams = nil;
    self.httpHeaderParams = nil;
    self.httpBodyParams = nil;
    self.requestBodyTransform = nil;
    self.httpMethod = nil;
    self.dataSource = nil;
    self.itemPath = nil;
    self.src = nil;
    self.itemTemplateNoData = nil;
    self.itemTemplateError = nil;
    self.itemTemplateLoading = nil;
    self.itemTemplateLoadMore = nil;
    self.sortField = nil;
    self.dateTS = nil;
    self.csvSeparator = nil;
    self.guidUsingField = nil;
    self.formId = nil;
    self.fullPath = nil;
    self.paginationHtthParam = nil;
    self.paginationPath = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];

    namespaces = [[NSMutableDictionary alloc] init];
    usingFields = [[NSMutableDictionary alloc] init];
    itemTemplates = [[NSMutableArray alloc] init];

    self.dateTS = [NSDate distantPast];

    self.itemIndex = NSNotFound;
    self.httpMethod = @"GET";
    self.paginationType = feedPaginantionNone;

    return self;
}

#pragma mark - Lifecycle

- (void)setItemIndex:(NSInteger)itemIndex_ {
    if (itemIndex == itemIndex_) return;

    itemIndex = itemIndex_;

    dataSource.itemIndex = itemIndex;
}

- (void)setDataSource:(AGDSFeed *)dataSource_ {
    if (dataSource == dataSource_) return;

    [dataSource release];
    dataSource = [dataSource_ retain];

    if (dataSource && dataSource.itemIndex != NSNotFound) {
        self.itemIndex = dataSource.itemIndex;
    }
}

#pragma mark - Variables

- (void)executeVariables:(id)sender {
    [AGACTIONMANAGER executeVariable:formId withSender:sender];
    [AGACTIONMANAGER executeVariable:src withSender:sender];
}

- (NSString *)fullPath:(NSString *)relativePath {
    if ([relativePath hasPrefix:@"/"]) {
        NSString *hostUri = src.value;
        if ([hostUri hasPrefix:@"/"]) {
            hostUri = fullPath;
        }

        return [[hostUri URLHostWithScheme] stringByAppendingURLPathComponent:relativePath];
    }

    return relativePath;
}

@end
