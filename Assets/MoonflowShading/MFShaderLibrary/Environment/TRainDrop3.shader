Shader"Moonflow/TestDrop3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct appdata
            {
               float4 vertex : POSITION;
               float2 uv : TEXCOORD0;
            };

            struct v2f
            {
               float4 vertex : SV_POSITION;
               float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float4 screenpos = i.screenPos;
                screenpos.xy = screenpos.xy/screenpos.w;
                float2 SinT = sin(_Time.xx * 2.0f * 3.1416 / _MainTex_ST.zw) * _MainTex_ST.xy;
                // rotate and scale UV
                float4 Cosines = float4(cos(SinT), sin(SinT));
                float2 CenteredUV = screenpos - float2(0.5f, 0.5f);
                float4 RotatedUV = float4(dot(Cosines.xz*float2(1,-1), CenteredUV)
                                         , dot(Cosines.zx, CenteredUV)
                                         , dot(Cosines.yw*float2(1,-1), CenteredUV)
                                         , dot(Cosines.wy, CenteredUV) ) + 0.5f;
                float4 UVLayer12 = /*ScalesLayer12 **/ RotatedUV.xyzw;
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy + float2(_MainTex_ST.z, frac(_MainTex_ST.w * _Time.x)) + UVLayer12.xy);
                half4 col1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy *2 + float2(_MainTex_ST.z, frac(_MainTex_ST.w * _Time.x)) + UVLayer12.zw);
                return col + col1;
            }
            ENDHLSL
        }
    }
}
