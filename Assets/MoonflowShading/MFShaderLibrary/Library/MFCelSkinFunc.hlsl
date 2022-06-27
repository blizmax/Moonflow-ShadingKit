#ifndef MF_CEL_SKIN_FUNC_INCLUDED
#define MF_CEL_SKIN_FUNC_INCLUDED

#include "MFMathUtility.hlsl"

Texture2D _MaskTex;
SamplerState sampler_MaskTex;


// UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
//
//     UNITY_DEFINE_INSTANCED_PROP(float4, _RimColor)
//     UNITY_DEFINE_INSTANCED_PROP(float, _RimFalloff)
//     UNITY_DEFINE_INSTANCED_PROP(float4, _HighLightColor)
//     UNITY_DEFINE_INSTANCED_PROP(float, _HighLightFalloff)
//     UNITY_DEFINE_INSTANCED_PROP(float, _SampleOffset)
//     UNITY_DEFINE_INSTANCED_PROP(float, _DepthThreshold)
//
//     UNITY_DEFINE_INSTANCED_PROP(float4, _MaskTex_ST)
//
//     UNITY_DEFINE_INSTANCED_PROP(float, _AngleAmp)
//     UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowBandwidth)
//
//     UNITY_DEFINE_INSTANCED_PROP(float, _NormalStr)
//     UNITY_DEFINE_INSTANCED_PROP(float, _FresnelRatio)
//     UNITY_DEFINE_INSTANCED_PROP(float, _FresnelStart)
//     UNITY_DEFINE_INSTANCED_PROP(float3, _StockingColor)
// UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// CBUFFER_START(UnityPerMaterial)
// float4 _RimColor;
// float _RimFalloff;
// float4 _HighLightColor;
// float _HighLightFalloff;
// float _SampleOffset;
// float _DepthThreshold;
// float4 _MaskTex_ST;
// float _AngleAmp;
// float _FaceShadowBandwidth;
// float _NormalStr;
// float _FresnelRatio;
// float _FresnelStart;
// float4 _StockingColor;
// CBUFFER_END


float SDFFace(float3 lightDir, float3 forward, float2 uv, half angleAmp, half bandWidth)
{
    float LR = cross(forward, -lightDir).y;
    // 左右翻转
    float2 flipUV = float2(1 - uv.x, uv.y);
    float lightMap = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, LR < 0 ? uv : flipUV).r;

    // float lightMap = LR < 0 ? lightMapL : lightMapR;
    lightDir.y = 0;
    forward.y = 0;
    float s = saturate(dot(-lightDir, forward) + angleAmp);
    return saturate(smoothstep(1-lightMap - bandWidth , 1-lightMap + bandWidth, s ));
}

struct MFStockingAttribute
{
    float4 tilling;
    float normalStr;
    float falloff;
    float fStart;
    float fRatio;
    float4 color;
    float4 rimColor;
};

half Fabric(half NdV, half falloff)
{
    half intensity = 1 - NdV;
    intensity = 0 - (intensity * 0.4 - pow(intensity, falloff) ) * 0.35;
    return saturate(intensity);
}
half StockingAlpha(half weavingMask, half NdV, half fStart, half fRatio)
{
    half rNdV = NdV * NdV;
    half rim = saturate(((1 - clamp(rNdV, 0, 1) ) * fRatio + fStart));
    rim = clamp(rim,0, 1);
    half mask = rNdV * weavingMask;
    mask = rim - mask * rim;
    return saturate(mask);
}


float3 StockingDiffuse(float3 baseColor, float2 uv, MFMatData matData, MFLightData lightData, MFStockingAttribute mfsa)
{
    half weaveMask = max(0, SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv * mfsa.tilling.xy + mfsa.tilling.zw) * mfsa.normalStr);
    half shade = lerp(0, lightData.NdL * 0.5 + 0.5, lightData.shadowAtten);
    half stockingFabric = Fabric(matData.ndv, mfsa.falloff) * clamp(shade, 0.5, 1);
    half stockingAlpha = StockingAlpha(weaveMask, matData.ndv, mfsa.fStart, mfsa.fRatio);
    half highlight = saturate(1-stockingAlpha) * half4(Curve(matData.ndv.xxx,15),1);
    baseColor = baseColor * (1-stockingAlpha) + mfsa.color.rgb * stockingAlpha + highlight*0.05;
    return lerp(baseColor, mfsa.rimColor, saturate(stockingFabric) * mfsa.color.a);
}


#endif