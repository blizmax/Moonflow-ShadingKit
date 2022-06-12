#ifndef MF_UTILITY_INCLUDED
#define MF_UTILITY_INCLUDED
#include "MFBase.hlsl"

float GetShadow(Varying i, MFMatData data)
{
#ifndef MF_SHADOW
    float shadow = MainLightRealtimeShadow(i.shadowCoord);
#else
    
#endif
    return shadow;
}
float CelShadow(Varying i, float shadow, float3 lightDir, float shadowAtten)
{
    return ApplyShadowFade(shadowAtten, ApplyShadowBias(i.posWS, i.normalWS, lightDir));
}
#endif