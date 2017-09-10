#import <Foundation/Foundation.h>

@interface JSONPathParser : NSObject

-(id) initWithJSON:(id)json andPath:(NSString*)path;
-(id) parse;

@end
