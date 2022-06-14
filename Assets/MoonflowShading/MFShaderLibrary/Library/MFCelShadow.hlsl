#ifndef MF_CELSHADOW_INCLUDED
#define MF_CELSHADOW_INCLUDED

float GetShadow(float4 shadowCoord)
{
// #ifndef MF_SHADOW
    float shadow = MainLightRealtimeShadow(shadowCoord);
// #else
    
// #endif
    return shadow;
}
float CelShadow(float3 posWS, float3 normalWS, float3 lightDir, float shadowAtten)
{
    return ApplyShadowFade(shadowAtten, ApplyShadowBias(posWS, normalWS, lightDir));
}
#endif