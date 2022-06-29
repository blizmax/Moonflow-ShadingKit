Shader"Hidden/Moonflow/RampMaker"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,0,1)
//        _TopTex("TopTex", 2D) = "white"{}
//        _BottomTex("BottomTex", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            
            float4 _TopColorArray[10];
            float _TopPointArray[10];
            float4 _BottomColorArray[10];
            float _BottomPointArray[10];

            float linearstep(float u, float left, float right)
            {
                return (u-left)/(right-left);
            }
            float4 GetTop(float u)
            {
                int i = 0;
                int left = 0;
                int right = 0;
                UNITY_UNROLL
                for (i = 0; i < 8; i++)
                {
                    if(_TopPointArray[i] < u)left = i;
                }
                for (i = 7; i >= 0; i--)
                {
                    if(_TopPointArray[i] >= u)right = i;
                }
                return lerp(_TopColorArray[left], _TopColorArray[right], linearstep(u, _TopPointArray[left], _TopPointArray[right]));
            }
            float4 GetBottom(float u)
            {
                int i = 0;
                int left = 0;
                int right = 0;
                UNITY_UNROLL
                for (i = 0; i < 8; i++)
                {
                    if(_BottomPointArray[i] < u)left = i;
                }
                for (i = 7; i >= 0; i--)
                {
                    if(_BottomPointArray[i] >= u)right = i;
                }
                return lerp(_BottomColorArray[left], _BottomColorArray[right], linearstep(u, _BottomPointArray[left], _BottomPointArray[right]));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return lerp(GetTop(i.uv.x), GetBottom(i.uv.x), 1 - i.uv.y);
            }
            ENDHLSL
        }
    }
}
