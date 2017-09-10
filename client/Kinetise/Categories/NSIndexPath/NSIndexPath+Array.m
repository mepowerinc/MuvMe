#import "NSIndexPath+Array.h"

@implementation NSIndexPath (Array)

+ (NSArray *)indexPathsWithRange:(NSRange)range inSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:range.length];
    NSUInteger end = range.location + range.length;

    for (NSUInteger idx = range.location; idx < end; idx++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }

    return indexPaths;
}

@end
