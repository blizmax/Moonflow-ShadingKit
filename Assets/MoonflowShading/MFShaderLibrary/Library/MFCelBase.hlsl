#ifndef MF_CEL_BASE_INCLUDED
#define MF_CEL_BASE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MFBase.hlsl"
#include "MFCelLighting.hlsl"
#include "MFCelGI.hlsl"



UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
   UNITY_DEFINE_INSTANCED_PROP(float4, _DiffuseTex_ST)
   UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

Texture2D _DiffuseTex;
SamplerState sampler_DiffuseTex;

Texture2D _NormalTex;
SamplerState sampler_NormalTex;

Texture2D _PBSTex;
SamplerState sampler_PBSTex;

// #define MF_CEL_NORMALTEX

//Keywords:
//MF_CEL_NORMALTEX
float4 BaseShading(Varying i)
{
   //MFMatData
   MFMatData matData = GetMatData(i, _DiffuseTex, sampler_DiffuseTex, _NormalTex, sampler_NormalTex, _PBSTex, sampler_PBSTex, _DiffuseTex_ST);
   MFLightData ld = GetLightingData(i, matData);
   //Diffuse

   //Lighting
   float3 diffuse;
   float3 specular;
   float3 GI;
   CelLight(i, matData, ld, diffuse, specular, GI);

   float4 color = matData.alpha;
   color.rgb = diffuse + specular + GI;
   return color;
}
#endif