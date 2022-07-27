// #ifndef MF_UTILITY_INCLUDED
// #define MF_UTILITY_INCLUDED
// #include "../ShaderLibrary/Common.hlsl"
//
// TEXTURE2D(_MainTex);
// SAMPLER(sampler_MainTex);
//
// UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
//    UNITY_DEFINE_INSTANCED_PROP(float, _MainTex_ST)
//    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
// UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
//
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
// float4 TemplateFragment(Varyings input) : SV_TARGET
// {
//    UNITY_SETUP_INSTANCE_ID(input);
//    float4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.baseUV);
//    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
//    return baseMap * baseColor;
// }
// #endif