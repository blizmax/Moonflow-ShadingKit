Shader"Moonflow/MeshGrass"
{
    Properties
    {
        [MFModuleDefinition(_MFGRASS_PREVIEW_ON, True)]_MFGrass_Preview("预览模式", Float) = 0
        _TopColor("顶部颜色", Color) = (0.34, 0.6, 0, 1)
        _MidBottomColor("中底部颜色", Color) = (0, 0.5, 0.29, 1)
        
        [MFEnumKeyword(Realistic Toon)]_MFGrassType("草渲染模式", Float) = 0
        [MFModuleDefinition(_MFGRASSTYPE_REALISTIC, false)]_Realistic("Realistic", Float) = 0
        [MFModuleDefinition(_MFGRASSTYPE_TOON, false)]_Toon("Toon", Float) = 0
        [MFSplitVector(_Toon, NoiseColor#0 NoiseColorScale#1)]_ToonGrassNoiseColor("卡渲偏色 卡渲偏色缩放", Vector) = (0.42, 0.6, 0.05, 1)
        
        [MFSplitVector(_Toon, ShadowStr#1#0_1 ShadowScale#1 ShadowSpeed#2)]_GrassCloudShadowParam_Preview("云影强度 云影缩放 云影滚动速度", Vector) = (1, 1, 0, 0)
        
        [MFModuleDefinition(_MFGRASS_QUAD_ON, True)]_MFGrass_Quad("面片模式", Float) = 0
        [MFModuleElement(_MFGrass_Quad)]_MainTex ("Texture", 2D) = "white" {}
        [MFModuleElement(_MFGrass_Quad)]_CutOff("Cut Off", Float) = 0.35
        
        [MFModuleDefinition(_MFGRASS_PROCEDURALMESH_ON, True)]_MFGrass_ProceduralMesh("程序化模型", Float) = 0
        [MFSplitVector(_MFGrass_ProceduralMesh, Height#1#0_5 Width#1#0_5 Tilt#1#0_1 Bend#1#0_1)]_MFGrass_Procedural_Param_Preview("草高 草宽 草斜度 草曲度", Vector) = (1,1,0.5,0.5)
        
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
            #pragma shader_feature _ _MFGRASS_PREVIEW_ON
            #pragma shader_feature _ _MFGRASS_PROCEDURALMESH_ON
            #pragma shader_feature _ _MFGRASS_QUAD_ON
            #pragma shader_feature _ _MFGRASS_MANUAL_ON
            #pragma shader_feature _MFGRASSTYPE_REALISTIC _MFGRASSTYPE_TOON
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "../Library/MFNoise.hlsl"

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
                float3 worldPos : TEXCOORD1;
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

            /*Preview*/
            Texture2D _GrassCloudShadowTex_Preview;
            SamplerState sampler_GrassCloudShadowTex_Preview;
            float4 _GrassCloudShadowParam_Preview;
            float4 _MFGrass_Procedural_Param_Preview;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                VertexPositionInputs vpi = GetVertexPositionInputs(v.vertex);
                o.worldPos = vpi.positionWS;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = 1;
                
            #ifdef _MFGRASS_QUAD_ON
                col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                clip(col.a-_CutOff);
            #endif

                /**********  基础颜色  **********/
                col.rgb *= lerp(_MidBottomColor, _TopColor, i.uv.y);

                /**********   卡渲偏色   ***********/
            #ifdef _MFGRASSTYPE_TOON
                float mixing = Noise_Gradient2D(i.worldPos.xz , _GrassCloudShadowParam_Preview.y);
                
            #endif

                /**********   云影   ***********/
                half cloudShadow = 1;
            #ifdef _MFGRASS_PREVIEW_ON
                cloudShadow = Noise_Gradient2D(i.worldPos.xz + _GrassCloudShadowParam_Preview.zw * frac(  _GrassCloudShadowParam_Preview.y * _Time.x), _GrassCloudShadowParam_Preview.y) * 2;
            #else
                
            #endif
                col.rgb = lerp(col.rgb, col.rgb * (1 - _GrassCloudShadowParam_Preview.x), cloudShadow);
                // col.rgb = col.rgb * (1 - _GrassCloudShadowParam_Preview.x);
                // return Noise_Gradient2D(i.worldPos.xz, _GrassCloudShadowParam_Preview.y);
                return col;
            }
            ENDHLSL
        }
    }
    CustomEditor "MFCelShaderGUI"
}
