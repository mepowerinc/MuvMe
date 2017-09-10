#import "AGActionManager.h"

@interface AGActionManager (Forms)

- (void)sendEmail:(id)sender :(id)object :(NSString *)address :(NSString *)controlAction :(NSString *)action :(NSString *)httpQueryParamsString :(NSString *)headerParamsString;
- (void)sendForm:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)action :(NSString *)httpQueryParamsString :(NSString *)headerParamsString;
- (void)sendFormV3:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)action :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)requestTransform :(NSString *)responseTransform;
- (void)sendAsyncForm:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)httpQueryParamsString :(NSString *)headerParamsString;
- (void)sendAsyncFormV3:(id)sender :(id)object :(NSString *)uri :(NSString *)controlAction :(NSString *)httpQueryParamsString :(NSString *)headerParamsString :(NSString *)bodyParamsString :(NSString *)httpMethod :(NSString *)requestTransform :(NSString *)responseTransform;
- (void)saveFormToLocalDB:(id)sender :(id)object :(NSString *)controlAction :(NSString *)tableName :(NSString *)operation :(NSString *)params :(NSString *)match :(NSString *)action;

@end
