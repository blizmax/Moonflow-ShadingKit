#ifndef MF_STRUCTS_INCLUDED
#define MF_STRUCTS_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
struct MFMatData
{
    float3 diffuse;
    float alpha;
    float metallic;
    float roughness;
    float roughness2;
    float occlusion;
    float3 normalTS;
    float3 normalWS;
    float3 emissive;
    float3 viewDirWS;
    float ndv;
    float oneMinusReflectivity;
    float3 specColor;
};

struct BaseAttributes
{
    float4 vertex : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 vertColor : COLOR;
    float4 uv0 : TEXCOORD0;
    float4 uv1 : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct BaseVarying
{
    float4 vertex : SV_POSITION;
    float3 color : COLOR;
    float2 uv : TEXCOORD0;
    float3 posWS : TEXCOORD1;
    float4 shadowCoord : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
    float3 tangentWS : TEXCOORD4;
    float3 bitangentWS : TEXCOORD5;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 6);
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
#endif