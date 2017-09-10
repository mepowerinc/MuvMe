#import "AGForm.h"
#import "AGActionManager.h"

@interface AGForm ()
@property(nonatomic, retain) AGValidationRule *invalidRule;
@property(nonatomic, retain) AGValidationRule *lastInvalidRule;
@end

@implementation AGForm

@synthesize formId;
@synthesize initialValue;
@synthesize value;
@synthesize validationRules;
@synthesize dependencies;
@synthesize invalidRule;
@synthesize lastInvalidRule;

#pragma mark - Initialization

- (void)dealloc {
    self.formId = nil;
    self.initialValue = nil;
    self.value = nil;
    self.invalidRule = nil;
    self.lastInvalidRule = nil;
    [validationRules release];
    [dependencies release];
    [super dealloc];
}

- (id)init {
    self = [super init];

    // validation
    validationRules = [[NSMutableArray alloc] init];

    // dependencies
    dependencies = [[NSMutableArray alloc] init];

    return self;
}

#pragma mark - Variables

- (void)executeVariables:(id)sender {
    [AGACTIONMANAGER executeVariable:formId withSender:sender];
    [AGACTIONMANAGER executeVariable:initialValue withSender:sender];
}

#pragma mark - Validation

- (BOOL)isValid:(id)value_ {
    for (AGValidationRule *validationRule in validationRules) {
        if (![validationRule check:value_]) {
            return NO;
            break;
        }
    }

    return YES;
}

- (BOOL)validate:(id)value_ {
    self.lastInvalidRule = invalidRule;
    self.invalidRule = nil;

    for (AGValidationRule *validationRule in validationRules) {
        if (![validationRule check:value_]) {
            self.invalidRule = validationRule;
            break;
        }
    }

    return !invalidRule;
}

- (void)invalidate {
    self.invalidRule = nil;
    self.lastInvalidRule = nil;
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    AGForm *obj = [[[self class] allocWithZone:zone] init];

    obj.formId = [[formId copy] autorelease];
    obj.initialValue = [[initialValue copy] autorelease];
    [obj.validationRules addObjectsFromArray:validationRules];
    [obj.dependencies addObjectsFromArray:dependencies];

    return obj;
}

@end
