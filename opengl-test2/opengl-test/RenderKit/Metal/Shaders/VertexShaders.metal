
#include <metal_stdlib>

using namespace metal;

#include "MTLShaderTypes.h"






vertex oneInputPipelineRasterizerData
oneInputVertexShader(const uint vertexID [[ vertex_id ]],
                     const device PositionVertex *position [[buffer(PPPVertexInputIndexPosition)]],
                     const device TexcoordVertex *texcoords [[buffer(PPPVertexInputIndexTexcoord)]])
{
    oneInputPipelineRasterizerData out;
    
    out.position = float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = position[vertexID].position.xy;
    
    out.texcoord = texcoords[vertexID].texcoord;
    return out;
}
