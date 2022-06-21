#ifndef MF_BASE_INCLUDED
#define MF_BASE_INCLUDED
#include "MFStructs.hlsl"

#include "MFCelLighting.hlsl"


BaseVarying vert(BaseAttributes v)
{
    BaseVarying o;
    o.vertex = TransformObjectToHClip(v.vertex);
    o.color = v.vertColor;
    o.uv = v.uv0;
    
    VertexPositionInputs vpi = GetVertexPositionInputs(v.vertex);
    o.posWS = vpi.positionWS;
    o.shadowCoord = TransformWorldToShadowCoord(vpi.positionWS);
    
    VertexNormalInputs vni = GetVertexNormalInputs(v.normalOS, v.tangentOS);
    o.bitangentWS = vni.bitangentWS;
    o.normalWS = vni.normalWS;
    o.tangentWS = vni.tangentWS;

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, o.lightmapUV);
    OUTPUT_SH(o.normalWS, o.vertexSH);
    return o;
}

MFMatData GetMatData(BaseVarying i, TEXTURE2D_PARAM(dName, dSampler), TEXTURE2D_PARAM(nName, nSampler), TEXTURE2D_PARAM(pName, pSampler), float4 baseST)
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
    data.normalWS = mul(data.normalTS.xyz, half3x3(i.tangentWS, i.bitangentWS, i.normalWS));
    data.emissive = pbsTex.w;
    data.viewDirWS = i.posWS - _WorldSpaceCameraPos;
    data.ndv = dot(data.normalWS, data.viewDirWS);
    data.oneMinusReflectivity = OneMinusReflectivityMetallic(data.metallic);
    data.specColor = lerp(0.04, data.diffuse, data.metallic);
    data.mask = 1;
    return data;
}

MFMatData GetMatData(BaseVarying i, float3 iDiffuse, float iAlpha, float2 iNormal, float iMetallic, float iRoughness, float iAO, float iEmission)
{
    MFMatData data;
    float4 realNormal = float4(iNormal.r, iNormal.g, 1, 1);
    data.diffuse = iDiffuse;
    data.alpha = iAlpha;
    data.metallic = iMetallic;
    data.roughness = iRoughness;
    data.roughness2 = data.roughness * data.roughness;
    data.occlusion = iAO;
    data.normalTS = UnpackNormal(realNormal);
    data.normalWS = mul(data.normalTS.xyz, half3x3(i.tangentWS, i.bitangentWS, i.normalWS));
    data.emissive = iEmission;
    data.viewDirWS = i.posWS - _WorldSpaceCameraPos;
    data.ndv = dot(normalize(data.normalWS), -normalize(data.viewDirWS));
    data.oneMinusReflectivity = OneMinusReflectivityMetallic(data.metallic);
    data.specColor = lerp(0.04, data.diffuse, data.metallic);
    data.mask = 1;
    return data;
}


void GetAnisotropyData(BaseVarying i, TEXTURE2D_PARAM(aName, aSampler), float2 uv, out float3 tangentWS, out float3 bitangentWS)
{
    float3 tangentTex = SAMPLE_TEXTURE2D(aName, aSampler, uv);
    tangentWS = normalize(mul(tangentTex, float3x3(i.tangentWS, i.bitangentWS, i.normalWS)));
    bitangentWS = cross(i.normalWS, tangentWS);
    tangentWS = cross(i.normalWS, bitangentWS);
}
void GetMaskEmissive(BaseVarying i, MFMatData md, TEXTURE2D_PARAM(mName, mSampler))
{
    
}



#endif