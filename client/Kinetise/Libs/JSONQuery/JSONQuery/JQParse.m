#import "JQParse.h"
#import "jq.h"
#import "jv.h"

FOUNDATION_EXPORT void JQParse(const char* jq_program, const char* data, size_t data_length, JV_OPTIONS flags, void (^callback)(const char* output,const NSUInteger length)){
    // state
    jq_state* jq = jq_init();
    if( !jq ){
        callback(nil, 0);
    }
    
    // compile program
    int compiled = jq_compile(jq, jq_program);
    if( !compiled ){
        callback(nil, 0);
    }
    
    // parser
    jv_parser* parser = jv_parser_new(0);
    jv_parser_set_buf(parser, data, (int)data_length, 0);
    
    // parsing
    jv value;
    while( jv_is_valid((value = jv_parser_next(parser))) ){
        jq_start(jq, value, 0);
        jv result;
        while( jv_is_valid(result = jq_next(jq)) ){
            jv output = jv_dump_string(result, 0);
            const char* outputStr = jv_string_value(output);
            int outputLen = jv_string_length_bytes(jv_copy(output));
            callback(outputStr, outputLen);
            jv_free(output);
        }
        jv_free(result);
        jq_teardown(&jq);
    }
    jv_parser_free(parser);
    
    /*
     struct jv_parser parser;
     NSMutableData* outputData = [NSMutableData dataWithCapacity:0];
     struct bytecode* bc = jq_compile([jq_program cStringUsingEncoding:NSUTF8StringEncoding]);
     struct jv_parser parser;
     jv_parser_init(&parser);
     jv_parser_set_buf(&parser, [self bytes], [self length], NO);
     jv value;
     while (jv_is_valid((value = jv_parser_next(&parser)))) {
     jq_state *jq = NULL;
     jq_init(bc, value, &jq, flags);
     jv result;
     while (jv_is_valid(result = jq_next(jq))) {
     jv output = jv_dump_string(result, JV_PRINT_PRETTY);
     const char* outputStr = jv_string_value(output);
     [outputData appendBytes:outputStr length:jv_string_length_bytes(output)];
     jv_free(output);
     }
     jv_free(result);
     jq_teardown(&jq);
     }
     jv_parser_free(&parser);
     bytecode_free(bc);
     return outputData;
     */
}
