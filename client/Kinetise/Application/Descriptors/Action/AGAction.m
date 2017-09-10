#import "AGAction.h"
#import "NSObject+Nil.h"

@implementation AGAction

@synthesize text;

#pragma mark - Initialization

- (void)dealloc {
    self.text = nil;
    [super dealloc];
}

+ (instancetype)actionWithText:(NSString *)text {
    if ([text isEqualToString:AG_NONE]) {
        return nil;
    }

    return [[[[self class] alloc] initWithText:text] autorelease];
}

- (instancetype)initWithText:(NSString *)text_ {
    self = [super init];

    self.text = text_;

    return self;
}

#pragma mark - Lifecycle

+ (BOOL)actionsRequireGPS:(NSArray *)actions {
    for (AGAction *action in actions) {
        if ([action containsScript:@"getGpsAccuracy()"] || [action containsScript:@"getGpsLongitude()"] || [action containsScript:@"getGpsLatitude()"]) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)containsScript:(NSString *)script {
    return [self.text containsString:script];
}

#pragma mark - Copying

- (instancetype)copyWithZone:(NSZone *)zone {
    AGAction *obj = [[[self class] allocWithZone:zone] init];

    obj.text = text;

    return obj;
}

@end
