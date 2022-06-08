#ifndef MF_CEL_BASE_INCLUDED
#define MF_CEL_BASE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MFCelLighting.hlsl"
#include "MFCelGI.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

TEXTURE2D(_NormalTex);
SAMPLER(sampler_NormalTex);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
   UNITY_DEFINE_INSTANCED_PROP(float, _MainTex_ST)
   UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

// struct Attributes{
//    float3 positionOS : POSITION;
//    float2 baseUV : TEXCOORD0;
//    UNITY_VERTEX_INPUT_INSTANCE_ID
// };
// struct Varyings {
//    float4 positionCS : SV_POSITION;
//    float2 baseUV : VAR_BASE_UV;
//    UNITY_VERTEX_INPUT_INSTANCE_ID
// };
// Varyings TemplateVertex(Attributes input)
// {   Varyings output;
//    UNITY_SETUP_INSTANCE_ID(input);
//    UNITY_TRANSFER_INSTANCE_ID(input, output);
//    float3 positionWS = TransformObjectToWorld(input.positionOS);
//    output.positionCS = TransformWorldToHClip(positionWS);
//    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
//    output.baseUV = input.baseUV * baseST.xy + baseST.zw;
//    return output;
// }

struct TBN
{
   float3 tangentWS;
   float3 bitangentWS;
   float3 normalWS;
};
#define MF_CEL_NORMALTEX

//Keywords:
//MF_CEL_NORMALTEX
float4 BaseShading(float2 uv, float3 positionWS, TBN tbn)
{
   //Normal
   float3 normalWS = tbn.normalWS;
   #ifdef MF_CEL_NORMALTEX
   float4 normalTex = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, uv);// b/a通道未使用
   float3 normalTS = UnpackNormal(normalTex);
   normalWS = mul(normalTS, float3x3(tbn.tangentWS, tbn.bitangentWS, tbn.normalWS));
   #endif

   //Vector
   float3 viewDirWS = positionWS - GetCameraPositionWS();

   //Diffuse
   float4 diffuse = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * _BaseColor;

   //Lighting
   
   
   return diffuse;
}
#endif