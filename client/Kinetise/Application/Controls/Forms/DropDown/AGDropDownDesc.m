#import "AGDropDownDesc.h"
#import "AGActionManager.h"
#import "NSArray+JSONPath.h"
#import "NSDictionary+JSONPath.h"
#import "NSObject+Nil.h"

@interface AGDropDownDesc (){
    NSMutableArray *items;
}
@property(nonatomic, assign) NSMutableArray *items;
@end

@implementation AGDropDownDesc

@synthesize listSrc;
@synthesize watermark;
@synthesize items;
@synthesize itemPath;
@synthesize textPath;
@synthesize valuePath;

#pragma mark - Initialization

- (void)dealloc {
    self.listSrc = nil;
    self.watermark = nil;
    self.itemPath = nil;
    self.textPath = nil;
    self.valuePath = nil;
    [items release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    
    items = [[NSMutableArray alloc] init];
    
    return self;
}

#pragma mark - Variables

- (void)executeVariables {
    [super executeVariables];
    
    // list src
    [AGACTIONMANAGER executeVariable:listSrc withSender:self];
    
    // watermark
    [AGACTIONMANAGER executeVariable:watermark withSender:self];
    
    // items
    [items removeAllObjects];
    
    BOOL hasValue = NO;
    id json = [NSJSONSerialization JSONObjectWithData:[listSrc.value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSArray *nodes = isNotNil(itemPath) ? [json nodesForJSONPath:itemPath] : @[json];
    
    for (id node in nodes) {
        NSString *title = nil;
        NSString *value = nil;
        
        if ([node isKindOfClass:[NSArray class]] || [node isKindOfClass:[NSDictionary class]]) {
            title = [self jsonStringValue:[node nodesForJSONPath:textPath].firstObject];
            value = [self jsonStringValue:[node nodesForJSONPath:valuePath].firstObject];
        } else {
            title = [self jsonStringValue:node];
            value = [self jsonStringValue:node];
        }
        
        if (isNotNil(title)) {
            title = [AGACTIONMANAGER executeString:title withSender:nil];
        }
        
        if (isNotNil(title) && isNotNil(value) ) {
            AGDSDropDownItem *item = [[AGDSDropDownItem alloc] init];
            [items addObject:item];
            item.title = title;
            item.value = value;
            [item release];
            
            if (isNotNil(form.initialValue.value) && [item.value isEqualToString:form.initialValue.value]) {
                hasValue = YES;
            }
        }
    }
    
    // initial value
    if (hasValue) {
        form.value = form.initialValue.value;
    } else {
        form.value = nil;
    }
}

- (NSString *)jsonStringValue:(id)node {
    if ([node isKindOfClass:[NSNumber class]]) {
        return [node stringValue];
    } else if ([node isKindOfClass:[NSString class]]) {
        return node;
    }
    
    return nil;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGDropDownDesc *obj = [super copyWithZone:zone];
    
    obj.listSrc = [[listSrc copy] autorelease];
    obj.watermark = [[watermark copy] autorelease];
    obj.itemPath = itemPath;
    obj.textPath = textPath;
    obj.valuePath = valuePath;
    
    return obj;
}

@end
