#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, JV_OPTIONS){
    SLURP = 1,
    RAW_INPUT = 2,
    PROVIDE_NULL = 4,
    
    RAW_OUTPUT = 8,
    COMPACT_OUTPUT = 16,
    ASCII_OUTPUT = 32,
    COLOUR_OUTPUT = 64,
    NO_COLOUR_OUTPUT = 128,
    
    FROM_FILE = 512,
    
    /* debugging only */
    DUMP_DISASM = 32768,
};

FOUNDATION_EXPORT void JQParse(const char* jq_program, const char* data, size_t data_length, JV_OPTIONS flags, void (^callback)(const char* output, const NSUInteger length));
