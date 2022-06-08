#ifndef MF_CEL_LIGHTING_INCLUDED
#define MF_CEL_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float, _ShadowStr)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

void CelLighting(float4 shadowCoord, float3 normalWS, out float3 lightDirWS, out float lightAtten, out float shadowAtten)
{
    Light mainLight = GetMainLight(shadowCoord);
    lightDirWS = mainLight.direction;
    lightDirWS.y = 0;
    half ndl = dot(normalWS, lightDirWS);
    shadowAtten = mainLight.shadowAttenuation * _ShadowStr + 1-_ShadowStr;
    lightAtten = max(0,ndl);
}

#endif