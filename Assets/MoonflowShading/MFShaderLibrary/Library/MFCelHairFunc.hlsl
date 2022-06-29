#ifndef MF_CEL_HAIR_INCLUDED
#define MF_CEL_HAIR_INCLUDED
#include "MFMathUtility.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct MFCelHairAttributes
{
    float specMaskOffset;
    float shift;
    float4 specColor1;
    float4 specColor2;
    float2 layerOffset;
};

float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
{
    float3 H = normalize(L + V);
    float dotTH = dot(T, H);
    float sinTH = sqrt(1.0 - dotTH * dotTH);
    sinTH =  ColorCurveMapping(sinTH, exponent);
    float dirAtten = smoothstep(-1, 0, saturate(dotTH+1));
    return saturate(dirAtten * sinTH);
}

float3 HairLighting (MFCelHairAttributes hairAttr, float3 tangent, float3 normal, float3 lightVec, 
         float3 viewVec, float2 uv, float smoothness, float shiftTex)
{
    float3 bitangent = -normalize(cross(tangent, normal));
    // shift tangents
    shiftTex *= hairAttr.specMaskOffset;
    float3 t1 = ShiftTangent(bitangent, normal, /*primaryShift*/hairAttr.shift + shiftTex);
    // float3 t2 = ShiftTangent(bitangent, normal, /*secondaryShift*/_Shift + shiftTex) ;
    // diffuse lighting
    smoothness = saturate(smoothness - 0.3);
    // specular lighting
    // add second specular term
    float3 specular = hairAttr.specColor1.rgb * StrandSpecular(t1, viewVec, lightVec, 0.1/hairAttr.layerOffset.x) * hairAttr.specColor1.a;
    specular += hairAttr.specColor2.rgb * StrandSpecular(t1, viewVec, lightVec, 0.1/hairAttr.layerOffset.y) * hairAttr.specColor2.a;
                
    // Final color
    // float3 o;
    // o.rgb = (diffuse + specular) * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv); /** lightColor*/;
    // o.rgb *= ambOcc; 
    // o.a = tex2D(tAlpha, uv);
            
    return specular;
}

#endif