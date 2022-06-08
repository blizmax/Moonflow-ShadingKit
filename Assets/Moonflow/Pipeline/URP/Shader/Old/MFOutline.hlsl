#ifndef MF_OUTLINE_INCLUDED
#define MF_OUTLINE_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
half _MFOutlineModelStrength;
CBUFFER_END
half4 _MFOutlineWDS;
half4 _MFOutlineColor;
#define _Width _MFOutlineWDS.x
#define _FadeDist _MFOutlineWDS.y
#define _FadeStart _MFOutlineWDS.z

Texture2D _MainTex;
SamplerState sampler_MainTex;

struct appdata
{
   float4 vertex : POSITION;
   float4 normal : NORMAL;
   float2 uv : TEXCOORD0;
   float3 color : COLOR;
};

struct v2f
{
   float4 vertex : SV_POSITION;
   float3 uv : TEXCOORD0;
};

v2f OutlineVertex (appdata v)
{
   v2f o;
   VertexNormalInputs normal_inputs = GetVertexNormalInputs(v.normal);
   // half3 worldPos = TransformObjectToWorld(v.vertex);
   half4 oriClip = TransformObjectToHClip(v.vertex);
   half3 clipNormal = TransformWorldToHClipDir(normal_inputs.normalWS);
   float depth = ComputeScreenPos(oriClip);
   o.vertex.xyz = oriClip + normalize(clipNormal) * _Width * 0.01 * oriClip.w * _MFOutlineModelStrength ? v.color.b : 1/** (depth- _ProjectionParams.y) / _ProjectionParams.y*/;
   o.vertex.w = oriClip.w;
   o.uv = half3(v.uv, saturate((_FadeStart - depth)/_FadeDist));
   return o;
}
half4 ReadMainTex(float2 uv)
{
   return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
}
#ifndef CustomOutlineMap
#define ReadTex(uv) ReadMainTex(uv);
#else
#define ReadTex(uv) ReadOtherTex(uv);
#endif
float4 OutlineFragment(v2f i) : SV_TARGET
{
   half4 col = ReadMainTex(i.uv);
   col.rgb = lerp(col.rgb,col.rgb * _MFOutlineColor.rgb, _MFOutlineColor.a);
   return half4(col.rgb, i.uv.z * col.a);
}
#endif