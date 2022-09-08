
#import "MNTPSubmesh.h"
#import "MNTPMaterial.h"

#import <vector>

@implementation MNTPSubmesh
{
    std::vector<uint32_t> _indexVector;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.material = [[MNTPMaterial alloc] init];
    }
    return self;
}

- (void)addIndex:(uint32_t)index {
    _indexVector.push_back(index);
}

- (void)removeLast {
    _indexVector.pop_back();
}

- (uint32_t *)indexBuffer {
    return &_indexVector[0];
}

- (NSUInteger)indexCount {
    return _indexVector.size();
}


- (void)updateIndexArray:(uint32_t *)indexArray count:(NSInteger)indexCount {
    _indexVector.resize(indexCount);
    std::copy(indexArray, indexArray + indexCount, _indexVector.begin());
}

@end
