#ifndef MF_BASE_INCLUDED
#define MF_BASE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
struct Attributes
{
    float4 vertex : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 vertColor : COLOR;
    float4 uv0 : TEXCOORD0;
    float4 uv1 : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct Varying
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

Varying vert(Attributes v)
{
    Varying o;
    o.vertex = TransformObjectToHClip(v.vertex);
    o.color = v.vertColor;
    o.uv = v.uv0;
    
    VertexPositionInputs vpi = GetVertexPositionInputs(v.vertex);
    o.posWS = vpi.positionWS;
    o.shadowCoord = TransformWorldToShadowCoord(vpi.positionWS);
    
    VertexNormalInputs vni = GetVertexNormalInputs(v.normalOS, v.tangentOS);
    o.normalWS = vni.normalWS;
    o.tangentWS = vni.tangentWS;
    o.bitangentWS = vni.bitangentWS;

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, o.lightmapUV);
    OUTPUT_SH(o.normalWS, o.vertexSH);
    return o;
}

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


MFMatData GetMatData(Varying i, TEXTURE2D_PARAM(dName, dSampler), TEXTURE2D_PARAM(nName, nSampler), TEXTURE2D_PARAM(pName, pSampler), float4 baseST)
{
    MFMatData data;
    float2 realUV = i.uv * baseST.xy + baseST.zw;
    float4 diffuseTex = SAMPLE_TEXTURE2D(dName, dSampler, realUV);
    float4 normalTex = SAMPLE_TEXTURE2D(nName, nSampler, realUV);
    float4 realNormal = float4(normalTex.r, normalTex.g, 0.5, 1);
    float4 pbsTex = SAMPLE_TEXTURE2D(pName, pSampler, realUV);
    data.diffuse = diffuseTex.rgb;
    data.alpha = diffuseTex.a;
    data.metallic = pbsTex.r;
    data.roughness = pbsTex.g;
    data.roughness2 = data.roughness * data.roughness;
    data.occlusion = pbsTex.b;
    data.normalTS = UnpackNormal(realNormal);
    data.normalWS = mul(data.normalTS, half3x3(i.tangentWS, i.bitangentWS, i.normalWS));
    data.emissive = pbsTex.w;
    data.viewDirWS = i.posWS - _WorldSpaceCameraPos;
    data.ndv = dot(data.normalWS, data.viewDirWS);
    data.oneMinusReflectivity = OneMinusReflectivityMetallic(data.metallic);
    data.specColor = lerp(0.04, data.diffuse, data.metallic);
    return data;
}


void GetAnisotropyData(Varying i, TEXTURE2D_PARAM(aName, aSampler), float2 uv, out float3 tangentWS, out float3 bitangentWS)
{
    float3 tangentTex = SAMPLE_TEXTURE2D(aName, aSampler, uv);
    tangentWS = normalize(mul(tangentTex, float3x3(i.tangentWS, i.bitangentWS, i.normalWS)));
    bitangentWS = cross(i.normalWS, tangentWS);
    tangentWS = cross(i.normalWS, bitangentWS);
}
void GetMaskEmissive(Varying i, MFMatData md, TEXTURE2D_PARAM(mName, mSampler))
{
    
}



#endif