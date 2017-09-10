#import <Foundation/Foundation.h>

#define SINGLETON_INTERFACE(CLASSNAME) \
    +(CLASSNAME *)sharedInstance; \
    + (void)end; \
    + (BOOL)isAllocated; \

#define SINGLETON_IMPLEMENTATION(CLASSNAME) \
    static CLASSNAME* g_sharedInstance = nil; \
    + (CLASSNAME *)sharedInstance \
    { \
        if (g_sharedInstance != nil) { \
            return g_sharedInstance; \
        } \
        static dispatch_once_t safer; \
        dispatch_once(&safer, ^(void) \
        { \
            g_sharedInstance = [[self alloc] init]; \
        }); \
        return g_sharedInstance; \
    } \
\
    + (id)allocWithZone:(NSZone *)zone \
    { \
        @synchronized(self) { \
            if (g_sharedInstance == nil) { \
                g_sharedInstance = [super allocWithZone:zone]; \
                return g_sharedInstance; \
            } \
        } \
        NSAssert(NO, @"[" #CLASSNAME \
                 " alloc] explicitly called on singleton class."); \
        return nil; \
    } \
    - (id)copyWithZone:(NSZone *)zone { \
        return self; \
    } \
    - (NSUInteger)retainCount { \
        return NSUIntegerMax; \
    } \
    - (id)retain { \
        return self; \
    } \
    - (oneway void)release { \
    } \
    - (id)autorelease { \
        return self; \
    } \
    + (void)end { \
        [g_sharedInstance dealloc]; \
        g_sharedInstance = nil; \
    } \
\
    + (BOOL)isAllocated { \
        return g_sharedInstance != nil; \
    }

