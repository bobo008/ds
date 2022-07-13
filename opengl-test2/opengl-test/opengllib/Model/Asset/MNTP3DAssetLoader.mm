
#import "MNTP3DAssetLoader.h"

#import "MNTP3DAsset.h"
#import "MNTPMesh.h"
#import "MNTPSubmesh.h"
#import "MNTPMaterial.h"

#import "NSArray+MNTExtend.h"

#import <simd/simd.h>
#import <vector>
#import <unordered_map>
#import <map>

// Implement `operator==` to use `MNTPVertexData` as a hash key in an unordered map.
bool operator==(const MNTPVertexData & lhs, const MNTPVertexData & rhs)
{
    return(simd::all(lhs.position == rhs.position) &&
           simd::all(lhs.normal == rhs.normal) &&
           simd::all(lhs.texcoord == rhs.texcoord));
}

// Implement a hash function for `MNTPVertexData` to use it as a key in an unordered map.
template<> struct std::hash<MNTPVertexData>
{
    std::size_t operator()(const MNTPVertexData& k) const
    {
        std::size_t hash = 0;
        for (uint w = 0; w < sizeof(MNTPVertexData) / sizeof(std::size_t); w++)
            hash ^= (((std::size_t*)&k)[w] ^ (hash << 8) ^ (hash >> 8));
        return hash;
    }
};

@implementation MNTP3DAssetLoader
{
    NSMutableArray<MNTPSubmesh *> *_submeshes;
    NSMutableDictionary<NSString *, MNTPMaterial *> *_materialDic;
    MNTPSubmesh *_currentSubmesh;
    MNTPMesh *_mesh;
    
    std::vector<vector_float3>  _positions;
    std::vector<vector_float3>  _normals;
    std::vector<vector_float2>  _texcoords;
    std::unordered_map<MNTPVertexData, uint32_t> _vertexMap;

    NSURL *_OBJURL;
    NSError *_error;
}

- (MNTP3DAsset *)loadAssetAtURL:(NSURL *)URL error:(NSError **)error {
    _OBJURL = URL;
    _submeshes = [NSMutableArray array];
    _materialDic = [NSMutableDictionary dictionary];
    
    [self parseOBJFile];
    if (_error) {
        *error = _error;
        return nil;
    }
    MNTP3DAsset *asset = [MNTP3DAsset new];
    asset.mesh = _mesh;
    return asset;
}

#pragma mark - Parse OBJ
- (void)parseOBJFile
{
    NSError *error;

    NSString *fileString = [[NSString alloc] initWithContentsOfURL:_OBJURL
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];

    if (!fileString) {
        NSLog(@"Failed to open .obj file, error: %@.", error);
        assert(!"Failed to open .obj file.");
        _error = error;
        return;
    }

    _mesh = [[MNTPMesh alloc] init];
    _mesh.name = [_OBJURL.lastPathComponent stringByDeletingPathExtension];
    
    NSArray<NSString*> *lines = [fileString componentsSeparatedByString:@"\n"];

    fileString = nil;

    for (NSString* line in lines) {
        [self readLine:line];
    }

    lines = nil;
    _mesh.submeshes = _submeshes.copy;
    _currentSubmesh = nil;
    _submeshes = nil;

    _positions.clear();
    _texcoords.clear();
    _normals.clear();
    _vertexMap.clear();
}

- (void)readLine:(NSString*)line
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;

    char scannedString[256];

    NSArray<NSString *> *array = [line componentsSeparatedByString:@" "];
    array = [array eav_arrayFilter:^BOOL(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.length > 0;
    }];
    NSString *name = array.firstObject;
    
    if (sscanf(line.UTF8String, " v %f %f %f", &x, &y, &z) == 3)
    {
        // If a position is specified
        _positions.push_back( (vector_float3) {x,y,z} );
    }
    else if (sscanf(line.UTF8String, " vt %f %f", &x, &y) == 2)
    {
        // A texture coordinate is specified
        _texcoords.push_back( (vector_float2) {x,y} );
    }
    else if (sscanf(line.UTF8String, " vt %f %f %f", &x, &y, &z) == 3)
    {
        // A texture coordinate is specified
        _texcoords.push_back( (vector_float2) {x,y} );
    }
    else if (sscanf(line.UTF8String, " vn %f %f %f", &x, &y, &z) == 3)
    {
        // A normal is specified
        _normals.push_back( (vector_float3) {x,y,z} );
    }
    else if ([name isEqualToString:@"f"]) {
        std::vector<uint32_t> fDataIdx;
        for (NSInteger i = 1; i < array.count; i++) {
            NSString *vStr = array[i];
            int vp, vt, vn;
            if (sscanf(vStr.UTF8String, "%d/%d/%d", &vp, &vt, &vn) == 3) {
                MNTPVertexData vertex;
                vertex.position = _positions[vp - 1];
                if (vn > 0) { // 美术那边模型文件导出的问题，发现会有0索引。
                    vertex.normal   = _normals  [vn - 1];
                } else {
                    vertex.normal = simd_make_float3(0, 0, 1);
                }
                vertex.texcoord = _texcoords[vt-1];
#ifdef DEBUG
                if (vertex.texcoord.x < 0 || vertex.texcoord.x > 1 || vertex.texcoord.y < 0 || vertex.texcoord.y > 1) {
                    NSLog(@"obj file error texcoord: %@", line);
                }
#endif
                fDataIdx.push_back([self findIndexOrPushVertex:vertex]);
            }
            else if (sscanf(vStr.UTF8String, "%d//%d", &vp, &vn) == 2) {
                MNTPVertexData vertex;
                vertex.position = _positions[vp - 1];
                if (vn > 0) { // 美术那边模型文件导出的问题，发现会有0索引。
                    vertex.normal   = _normals  [vn - 1];
                } else {
                    vertex.normal = simd_make_float3(0, 0, 1);
                }
                fDataIdx.push_back([self findIndexOrPushVertex:vertex]);
            }
        }
        
        for (NSInteger i = 1; i < fDataIdx.size() - 1; i++) {
            [_currentSubmesh addIndex:fDataIdx[0]];
            [_currentSubmesh addIndex:fDataIdx[i]];
            [_currentSubmesh addIndex:fDataIdx[i + 1]];
        }
    }
    else if (sscanf(line.UTF8String, " mtllib %256s", scannedString) == 1)
    {
        NSString *materialFileNameString = [[NSString alloc] initWithUTF8String:scannedString];
        NSURL *materialFileURL = [_OBJURL URLByDeletingLastPathComponent];
        materialFileURL = [materialFileURL URLByAppendingPathComponent:materialFileNameString];
        [self parseMaterialFile:materialFileURL];
    }
    else if (sscanf(line.UTF8String, " usemtl %256s", scannedString) == 1)
    {
        NSString *materialNameString = [[NSString alloc] initWithUTF8String:scannedString];
        _currentSubmesh = [self createSubmeshWithMaterialName:materialNameString];
        assert(_currentSubmesh);
    }
}

- (void)parseMaterialFile:(NSURL*)materialURL
{
    NSError *error;
    NSString *fileString = [[NSString alloc] initWithContentsOfURL:materialURL
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];

    if(!fileString)
    {
        NSLog(@"Failed to open .mtl file, error: %@.", error);
        assert(!"Failed to open .mtl file.");
        _error = error;
    }

    NSArray<NSString*> *lines = [fileString componentsSeparatedByString:@"\n"];

    fileString = nil;

    MNTPMaterial *currentMaterial;

    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    char scannedString[256];

    for(NSString* line in lines)
    {
        if (sscanf(line.UTF8String, " newmtl %256s", scannedString) == 1)
        {
            NSString *materialNameString = [[NSString alloc] initWithUTF8String:scannedString];

            currentMaterial = [[MNTPMaterial alloc] init];
            _materialDic[materialNameString] = currentMaterial;
        }
        else if (sscanf(line.UTF8String, " map_Kd %256s", scannedString) == 1)
        {
            assert(currentMaterial);

            NSString *textureString = [[NSString alloc] initWithUTF8String:scannedString];
            currentMaterial.map_kd = [textureString componentsSeparatedByString:@"/"].lastObject;
        }
        else if (sscanf(line.UTF8String, " Ka %f %f %f", &x, &y, &z) == 3)
        {
            assert(currentMaterial);
//            if (x != 0 || y != 0 || z != 0) {
                currentMaterial.ambientColor = simd_make_float3(x, y, z);
//            }
        }
        else if (sscanf(line.UTF8String, " Kd %f %f %f", &x, &y, &z) == 3)
        {
            assert(currentMaterial);
            if (x != 0 || y != 0 || z != 0) {
                currentMaterial.diffuseColor = simd_make_float3(x, y, z);
            }
        }
        else if (sscanf(line.UTF8String, " Ks %f %f %f", &x, &y, &z) == 3)
        {
            assert(currentMaterial);
//            if (x != 0 || y != 0 || z != 0) {
                currentMaterial.specularColor = simd_make_float3(x, y, z);
//            }
        }
    }
}

- (MNTPSubmesh *)createSubmeshWithMaterialName:(NSString *)name {
    MNTPSubmesh *subMesh = [[MNTPSubmesh alloc] init];
    subMesh.name = name;
    if (_materialDic[name]) {
        subMesh.material = [_materialDic[name] copy];
        if (subMesh.material.map_kd.length > 0) {
            NSURL *URL = [_OBJURL URLByDeletingLastPathComponent];
            URL = [URL URLByAppendingPathComponent:subMesh.material.map_kd];
            subMesh.baseColorName = subMesh.material.map_kd;
            subMesh.baseColorMapURL = URL;
        }
    } else {
        NSAssert(NO, @"模型数据错误");
        subMesh.material = [[MNTPMaterial alloc] init];
    }
    [_submeshes addObject:subMesh];
    return subMesh;
}

- (uint32_t)findIndexOrPushVertex:(const MNTPVertexData &)vertex
{
    auto ref = _vertexMap.find(vertex);

    if(ref == _vertexMap.end())
    {
        _vertexMap.insert(std::pair<MNTPVertexData,uint32_t>(vertex, _mesh.vertexCount));
        [_mesh addVertex:vertex];
        return (uint32_t)(_mesh.vertexCount - 1);
    }
    else
    {
        return ref->second;
    }
}


@end
