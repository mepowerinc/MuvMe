#import "JSONPathParser.h"

@interface JSONPathParser(){
    NSMutableArray* results;
    NSScanner* scanner;
}
@property(nonatomic,retain) NSMutableArray* results;
@end

@implementation JSONPathParser

@synthesize results;

-(void) dealloc{
    self.results = nil;
    [scanner release];
    [super dealloc];
}

-(id) initWithJSON:(id)json andPath:(NSString*)path{
    self = [super init];
    
    // scanner
    scanner = [[NSScanner alloc] initWithString:path];
    scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // results
    self.results = [NSMutableArray arrayWithObject:json];
    
    return self;
}

-(id) parse{
    [scanner scanString:@"$" intoString:nil];
    
    while( !scanner.isAtEnd ){
        if( [self parseChild] ){
        }else if( [self parseArray] ){
        }else if( [self parseDot] ){
        }else{
            NSLog(@"Invalid JSONPath: %@", scanner.string);
            return @[];
        }
    }
    
    return results;
}

#pragma mark - Parse

-(BOOL) parseChild{
    if( ![scanner scanString:@"['" intoString:nil] ) return NO;
    
    NSString* childName = nil;
    [scanner scanUpToString:@"']" intoString:&childName];
    
    if( [scanner scanString:@"']" intoString:nil] ){
        NSArray* allObjects = [NSArray arrayWithArray:results];
        [results removeAllObjects];
        for(id object in allObjects){
            if( [object isKindOfClass:[NSDictionary class]] ){
                id child = object[childName];
                if( child ) [results addObject: child ];
            }
        }
    }else{
        NSAssert(NO, @"Expected '']' to close child operator");
    }
    
    return YES;
}

-(BOOL) parseDot{
    if( ![scanner scanString:@"." intoString:nil] ) return NO;
    
    NSString* childName = nil;
    
    if( [self parseWildcard] ){
    }else if( [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@".["] intoString:&childName] ){
        NSArray* allObjects = [NSArray arrayWithArray:results];
        [results removeAllObjects];
        for(id object in allObjects){
            if( [object isKindOfClass:[NSDictionary class]] ){
                id child = object[childName];
                if( child ) [results addObject: child ];
            }
        }
    }
    
    return YES;
}

-(BOOL) parseArray{
    if( ![scanner scanString:@"[" intoString:nil] ) return NO;
    
    if( [self parseWildcard] ){
    }else if( [self parseArrayIndex] ){}else{
        NSAssert(NO, @"Expected '*' or integer index in array");
    }
    
    if( ![scanner scanString:@"]" intoString:nil] ){
        NSAssert(NO, @"Expected ']' to close array operator");
    }
    
    return YES;
}

-(BOOL) parseArrayIndex{
    NSInteger arrayIndex;
    if( ![scanner scanInteger:&arrayIndex] ) return NO;
    
    NSArray* allObjects = [NSArray arrayWithArray:results];
    [results removeAllObjects];
    for(id object in allObjects){
        if( [object isKindOfClass:[NSArray class]] ){
            if( arrayIndex<[object count] ){
                id child = object[arrayIndex];
                if( child ) [results addObject: child ];
            }
        }
    }
    
    return YES;
}

-(BOOL) parseWildcard{
    if( ![scanner scanString:@"*" intoString:nil] ) return NO;
    
    NSArray* allObjects = [NSArray arrayWithArray:results];
    [results removeAllObjects];
    
    for(id object in allObjects){
        if( [object isKindOfClass:[NSArray class]] ){
            [results addObjectsFromArray:object];
        }else if( [object isKindOfClass:[NSDictionary class]] ){
            [results addObjectsFromArray: [object allValues] ];
        }
    }
    
    return YES;
}

@end
