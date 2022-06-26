#ifndef MF_CEL_SKIN_FUNC_INCLUDED
#define MF_CEL_SKIN_FUNC_INCLUDED

#include "MFMathUtility.hlsl"

Texture2D _MaskTex;
SamplerState sampler_MaskTex;

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)

    UNITY_DEFINE_INSTANCED_PROP(float4, _RimColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _RimFalloff)
    UNITY_DEFINE_INSTANCED_PROP(float4, _HighLightColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _HighLightFalloff)
    UNITY_DEFINE_INSTANCED_PROP(float, _SampleOffset)
    UNITY_DEFINE_INSTANCED_PROP(float, _DepthThreshold)

    UNITY_DEFINE_INSTANCED_PROP(float4, _MaskTex_ST)

    UNITY_DEFINE_INSTANCED_PROP(float, _AngleAmp)
    UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowBandwidth)

    UNITY_DEFINE_INSTANCED_PROP(float, _NormalStr)
    UNITY_DEFINE_INSTANCED_PROP(float, _FresnelRatio)
    UNITY_DEFINE_INSTANCED_PROP(float, _FresnelStart)
    UNITY_DEFINE_INSTANCED_PROP(float3, _StockingColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)


float SDFFace(float3 lightDir, float3 forward, float2 uv)
{
    float LR = cross(forward, -lightDir).y;
    // 左右翻转
    float2 flipUV = float2(1 - uv.x, uv.y);
    float lightMap = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, LR < 0 ? uv : flipUV).r;

    // float lightMap = LR < 0 ? lightMapL : lightMapR;
    lightDir.y = 0;
    forward.y = 0;
    float s = saturate(dot(-lightDir, forward) + _AngleAmp);
    return saturate(smoothstep(1-lightMap - _FaceShadowBandwidth , 1-lightMap + _FaceShadowBandwidth, s ));
}

half Fabric(half NdV)
{
    half intensity = 1 - NdV;
    intensity = 0 - (intensity * 0.4 - pow(intensity, _RimFalloff) ) * 0.35;
    return saturate(intensity);
}
half StockingAlpha(half weavingMask, half NdV, half2 uv)
{
    half rNdV = NdV * NdV;
    half rim = saturate(((1 - clamp(rNdV, 0, 1) ) * _FresnelRatio + _FresnelStart));
    rim = clamp(rim,0, 1);
    half mask = rNdV * weavingMask;
    mask = rim - mask * rim;
    return saturate(mask);
}


float3 StockingDiffuse(float3 baseColor, float2 uv, MFMatData matData, MFLightData lightData)
{
    half weaveMask = max(0, SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv * _MaskTex_ST.xy + _MaskTex_ST.zw) * _NormalStr);
    half shade = lerp(0, lightData.NdL * 0.5 + 0.5, lightData.shadowAtten);
    half stockingFabric = Fabric(matData.ndv) * clamp(shade, 0.5, 1);
    half stockingAlpha = StockingAlpha(weaveMask, matData.ndv, uv);
    half highlight = saturate(1-stockingAlpha) * half4(Curve(matData.ndv.xxx,15),1);
    baseColor = baseColor * (1-stockingAlpha)+_StockingColor * stockingAlpha + highlight*0.05;
    return lerp(baseColor, _RimColor, saturate(stockingFabric));
}

float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
{
    float3 H = normalize(L + V);
    float dotTH = dot(T, H);
    float sinTH = sqrt(1.0 - dotTH * dotTH);
    sinTH =  ColorCurveMapping(sinTH, exponent);
    float dirAtten = smoothstep(-1, 0, saturate(dotTH+1));
    return saturate(dirAtten * sinTH);
}
#endif