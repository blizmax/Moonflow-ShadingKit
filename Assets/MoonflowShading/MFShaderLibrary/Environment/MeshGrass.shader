Shader"Moonflow/MeshGrass"
{
    Properties
    {
        _TopColor("顶部颜色", Color) = (0.34, 0.6, 0, 1)
        _MidBottomColor("中底部颜色", Color) = (0, 0.5, 0.29, 1)
        
        [MFEnumKeyword(Realistic Toon)]_MFGrassType("草渲染模式", Float) = 0
        [MFModuleDefinition(_MFGRASSTYPE_REALISTIC, false)]_Realistic("Realistic", Float) = 0
        [MFModuleDefinition(_MFGRASSTYPE_TOON, false)]_Toon("Toon", Float) = 0
        
        [MFModuleElement(_Toon)]_NoiseColor("卡渲偏色", Color) = (0.42, 0.6, 0.05, 1)
        
        [MFModuleDefinition(_MFGRASS_QUAD_ON, True)]_MFGrass_Quad("面片模式", Float) = 0
        [MFModuleElement(_MFGrass_Quad)]_MainTex ("Texture", 2D) = "white" {}
        [MFModuleElement(_MFGrass_Quad)]_CutOff("Cut Off", Float) = 0.35
        
        [MFModuleDefinition(_MFGRASS_MANUAL_ON, True)]_MFGrass_Manual("手动模式", Float) = 0
        [MFEnumKeyword(_MFGRASS_MANUAL_ON, Type1 Type2)]_GrassType("草类型", Float) = 0
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
            #pragma shader_feature _ _MFGRASS_MANUAL_ON
            #pragma shader_feature _MFGRASSTYPE_REALISTIC _MFGRASSTYPE_TOON
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct appdata
            {
                uint instanceID : SV_InstanceID;
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct GrassProcedualData
            {
                float3 positionP;
                float2 facingP;
                float windStrP;
                float hashP;
                float typeP;
                float2 clumpFacingP;
                float clumpColor;
                float height;
                float width;
                float tilt;
                float Bend;
                float SideCurve;
            };
            StructuredBuffer<float4x4> _GrassProcedualData;

            Texture2D _MainTex;
            SamplerState sampler_MainTex;

            CBUFFER_START(UnityPerMaterial)
            half _CutOff;
            float4 _MainTex_ST;
            float3 _TopColor;
            float3 _MidBottomColor;
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
                half4 col = 1;
                #ifdef _MFGRASS_QUAD_ON
                col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                clip(col.a-_CutOff);
                #endif
                col.rgb *= lerp(_MidBottomColor, _TopColor, i.uv.y);
                return col;
            }
            ENDHLSL
        }
    }
    CustomEditor "MFCelShaderGUI"
}
