#import "AGTextInputDesc.h"

@interface AGPasswordDesc : AGTextInputDesc {
    AGEncryptionType encryptionType;
}

@property(nonatomic, assign) AGEncryptionType encryptionType;

@end
