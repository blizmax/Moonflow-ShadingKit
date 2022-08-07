Shader"Moonflow/MeshGrass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MFModuleDefinition(_MFGRASS_QUAD_ON, True)]_MFGrass_Quad("面片模式", Float) = 0
        [MFModuleElement(_MFGrass_Quad)]_CutOff("Cut Off", Float) = 0.35
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Cull Off
		AlphaToMask Off
        
        Pass
        {
            
            Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ _MFGRASS_QUAD_ON
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

            CBUFFER_START(UnityPerMaterial)
            half _CutOff;
            float4 _MainTex_ST;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                #ifdef _MFGRASS_QUAD_ON
                clip(col.a-_CutOff);
                #endif
                return col;
            }
            ENDHLSL
        }
    }
}
