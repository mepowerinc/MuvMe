#import "AGScriptParser.h"
#import "NSObject+Nil.h"
#import "NSString+VariableEscaping.h"

@interface AGScriptParser (){
    NSScanner *scanner;
}
@property(nonatomic, copy) id (^parseBlock)(id target, NSString *method, NSArray *attributes);
@end

@implementation AGScriptParser

@synthesize parseBlock;

- (void)dealloc {
    self.parseBlock = nil;
    [scanner release];
    [super dealloc];
}

- (id)initWithString:(NSString *)string {
    self = [super init];

    if (isNil(string) ) string = @"";

    scanner = [[NSScanner alloc] initWithString:string];
    scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    return self;
}

- (id)parse {
    id result = nil;

    if (![self parseDynamic:&result]) {
        result = scanner.string;
    }

    return result;
}

- (id)parseUsingBlock:(id (^)(id target, NSString *method, NSArray *attributes))block {
    self.parseBlock = block;
    scanner.scanLocation = 0;

    return [self parse];
}

#pragma mark - Parse

- (BOOL)parseDynamic:(id *)result {
    if (![scanner scanString:@"[d]" intoString:nil]) {
        return NO;
    }

    if (![self parseMethodsChain:result]) {
        NSAssert(NO, @"Expected method inside dynamic");
        return NO;
    }

    if (![scanner scanString:@"[/d]" intoString:nil]) {
        NSAssert(NO, @"Expected '[/d]' to close dynamic");
        return NO;
    }

    return YES;
}

- (BOOL)parseMethodsChain:(id *)result {
    BOOL didScan = NO;

    while ([self parseMethod:*result withResult:result]) {
        didScan = YES;
        if (![scanner scanString:@";" intoString:nil]) {
            if (![scanner scanString:@"." intoString:nil]) break;
        }
    }

    [scanner scanString:@";" intoString:nil];

    return didScan;
}

- (BOOL)parseMethod:(id)target withResult:(id *)result {
    NSMutableArray *arguments = nil;
    NSString *method = nil;

    NSInteger scanLocation = scanner.scanLocation;

    if ([scanner scanUpToString:@"(" intoString:&method]) {
        if ([scanner scanString:@"(" intoString:nil]) {
            if ([scanner scanString:@")" intoString:nil]) {
                *result = parseBlock(target, method, arguments);
                return YES;
            } else {
                [self parseArguments:&arguments];
                if (![scanner scanString:@")" intoString:nil]) {
                    NSAssert(NO, @"Expected ')' to close method");
                } else {
                    *result = parseBlock(target, method, arguments);
                    return YES;
                }
            }
        }
    }
    scanner.scanLocation = scanLocation;

    return NO;
}

- (BOOL)parseArguments:(NSMutableArray * *)result {
    *result = [NSMutableArray array];

    NSMutableString *argument;
    while ([self parseArgument:&argument]) {
        if (argument) {
            [*result addObject:argument];
        } else {
            [*result addObject:[NSNull null] ];
        }
        if (![scanner scanString:@"," intoString:nil]) break;
    }

    return YES;
}

- (BOOL)parseArgument:(NSMutableString * *)result {
    return [self parseString:result] || [self parseMethodsChain:result];
}

- (BOOL)parseString:(NSMutableString * *)result {
    *result = [NSMutableString string];

    if (![scanner scanString:@"'" intoString:nil]) {
        return NO;
    }

    scanner.charactersToBeSkipped = nil;

    // unescaping
    NSString *plainText;
    BOOL isStringClosed = NO;

    while ([scanner scanUpToString:@"'" intoString:&plainText]) {
        [scanner scanString:@"'" intoString:nil];
        if ([plainText hasSuffix:@"\\"]) {
            [*result appendString:[[plainText stringByAppendingString:@"'"] variableUnescape] ];
        } else {
            [*result appendString:[plainText variableUnescape] ];
            isStringClosed = YES;
            break;
        }
    }

    if (!isStringClosed && ![scanner scanString:@"'" intoString:nil]) {
        NSAssert(NO, @"Expected ' to close string");
        return NO;
    }

    scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    return YES;
}

@end
