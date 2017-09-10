#import "AGActionManager+Controls.h"
#import "AGLocalizationManager.h"
#import "AGFormClientProtocol.h"
#import "AGCompoundButtonDesc.h"
#import "AGApplication+Control.h"
#import "AGPhotoDesc.h"
#import "NSObject+Nil.h"
#import "NSData+Base64.h"

@implementation AGActionManager (Controls)

- (AGControlDesc *)getControl:(id)sender :(id)object :(NSString *)controlId {
    if ([object isKindOfClass:[AGDesc class]]) {
        return [AGAPPLICATION getControlDesc:controlId withParent:object];
    }

    return [AGAPPLICATION getControlDesc:controlId];
}

- (id)getContext:(id)sender :(id)object {
    return AGAPPLICATION.currentContext;
}

- (NSString *)getActiveItemField:(id)sender :(id)object :(NSString *)field {
    AGFeed *feed = AGAPPLICATION.currentContext;
    AGDSFeed *feedDataSource = feed.dataSource;
    AGDSFeedItem *feedItemDataSource = [feedDataSource.items objectAtIndex:feed.itemIndex ];

    NSString *value = [feedItemDataSource.values objectForKey:field ];
    if (!value) value = [AGLOCALIZATION localizedString:@"NODE_NOT_FOUND"];

    return value;
}

- (NSString *)getItemField:(id)sender :(id)object :(NSString *)field {
    if (![object conformsToProtocol:@protocol(AGFeedClientProtocol)]) return nil;

    AGFeed *feed = [((id < AGFeedClientProtocol >)object) feed];
    AGDSFeed *feedDataSource = feed.dataSource;
    AGDSFeedItem *feedItemDataSource = feedDataSource.items[ ((AGControlDesc *)sender).itemIndex ];

    NSString *value = feedItemDataSource.values[ field ];
    if (!value) value = [AGLOCALIZATION localizedString:@"NODE_NOT_FOUND"];

    return value;
}

- (AGControlDesc *)getItem:(id)sender :(id)object {
    if (![object conformsToProtocol:@protocol(AGFeedClientProtocol)]) return nil;

    NSInteger itemIndex = ((AGControlDesc *)sender).itemIndex;
    id<AGFeedClientProtocol> feedClient = object;

    return [feedClient feedControls][itemIndex];
}

- (NSString *)getValue:(id)sender :(id)object {
    if (![object conformsToProtocol:@protocol(AGFormClientProtocol)]) return @"";

    id<AGFormClientProtocol> formClient = object;
    AGForm *form = formClient.form;

    NSString *value = nil;

    if ([formClient isKindOfClass:[AGCompoundButtonDesc class]]) {
        value = [form.value boolValue] ? @"true" : @"false";
    } else if ([formClient isKindOfClass:[AGPhotoDesc class]]) {
        if (isNotEmpty(form.value) ) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:form.value];
            value = [data base64EncodedString];
            [data release];
        }
    } else {
        value = form.value;
    }

    if (!value) value = @"";

    return value;
}

- (void)setValue:(id)sender :(id)object :(NSString *)value {
    // need to set desc and control view if exists !!!
    if (!value) value = @"";

    id<AGFormClientProtocol> formClient = object;
    AGForm *form = formClient.form;

    if ([formClient isKindOfClass:[AGCompoundButtonDesc class]]) {
        form.value = @([[value lowercaseString] isEqualToString:@"true"]);
        value = [form.value boolValue] ? @"true" : @"false";
    }
}

@end
