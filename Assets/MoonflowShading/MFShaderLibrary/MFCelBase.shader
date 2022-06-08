Shader"Moonflow/CelBase"
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
            HLSLPROGRAM
            #pragma shader_feature MF_CEL_NORMALTEX
            #pragma vertex vert
            #pragma fragment frag
            #include "Library/MFCelBase.hlsl"
            // #include "Library/MFCelLighting.hlsl"
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
            #ifdef MF_CEL_NORMALTEX
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
            #else
                float3 normalWS : TEXCOORD4;
            #endif
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = BaseShading(i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
