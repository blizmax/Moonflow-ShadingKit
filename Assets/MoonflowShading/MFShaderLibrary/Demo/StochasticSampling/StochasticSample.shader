Shader"Demo/StochasticSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(None, Inigo1, Inigo2, Inigo3O, Pastebin, ProcedualTAB)]_Type("Sample Type", Float) = 0
        [MFEasyTex]_NoiseTex("Noise", 2D) = "gray"{}
        _rendertype("RenderType", Float) = 1
        _blendmode("BlendMode", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma shader_feature _TYPE_NONE _TYPE_INIGO1 _TYPE_INIGO2 _TYPE_INIGO3O _TYPE_PASTEBIN _TYPE_PROCEDUALTAB
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "../../Utility/MFSampleExtension.hlsl"

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

            Texture2D _NoiseTex;
            SamplerState sampler_NoiseTex;
            float4 _NoiseTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                half4 col = 0;
            #ifdef _TYPE_NONE
                col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
            #elif defined(_TYPE_INIGO1)
                col = InigoRepetition1(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
            #elif defined(_TYPE_INIGO2)
                col = InigoRepetition2(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
            #elif defined(_TYPE_INIGO3O)
                col = InigoRepetition3O(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw, _NoiseTex, sampler_NoiseTex);
            #elif defined(_TYPE_PASTEBIN)
                col = PastebinRepetition(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
            #elif defined(_TYPE_PROCEDUALTAB)
                col = ProcedualTAB(_MainTex, sampler_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
            #endif
                
                return col;
            }
            ENDHLSL
        }
    }
    CustomEditor"MFCelShaderGUI"
}
