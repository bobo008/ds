
#import "MNTPMaterial.h"

@implementation MNTPMaterial

- (instancetype)init {
    self = [super init];
    if (self) {
        _ambientColor = 1.0f;
        _diffuseColor = 1.0f;
        _specularColor = 1.0f;
        _shininess = 128.f;
        _alpha = 1.f;
        _map_kd = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MNTPMaterial *material = [[MNTPMaterial alloc] init];
    material.ambientColor = _ambientColor;
    material.diffuseColor = _diffuseColor;
    material.specularColor = _specularColor;
    material.shininess = _shininess;
    material.alpha = _alpha;
    material.map_kd = _map_kd;
    return material;
}

@end
