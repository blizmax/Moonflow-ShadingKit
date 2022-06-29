Shader"Moonflow/CelBase"
{
    Properties
    {
//        [MFHeader(CelBase)]
        [KeywordEnum(Base, Hair, FaceSDF, Stocking)]_MFCel("MF Cel Type", Float) = 0
        /*======= Base =======*/
        [MFModuleHeader(Base)]
        _BaseColor("Color", Color) = (1,1,1,1)
        [MFPublicTex]_DiffuseTex ("Diffuse Tex", 2D) = "white" {}
        [MFPublicTex]_NormalTex("Normal Tex", 2D) = "bump" {}
        [MFPublicTex]_PBSTex("Data Tex", 2D) = "black" {}
        [MFRamp]_RampTex("Ramp Tex", 2D) = "white"{}
        _BaseTex_ST("TileOffset", Vector) = (1,1,0,0)
        
        _SelfShadowStr("Self Shadow Str", Range(0,1)) = 0.75
        _LitEdgeBandWidth("Lit Edge BandWidth", Range(0.001,1))=0.15
        _LitIndirectAtten("Lit Indirect Atten",Range(0,1)) = 0.5
        _EnvironmentEffect("EnvironmentEffect", Range(0,1)) = .2
        
        /*======= Rim =======*/
        [Space(10)]
        [MFModuleHeader(Rim)]
        [HDR]_RimColor("Rim Color", Color) = (0.7,0.2,0.17,1)
        [PowerSlider]_RimFalloff("Rim Falloff", Range(0.001, 10)) = 2
        
        /*======= HighLight =======*/
        [Space(10)]
        [MFModuleHeader(Highlight)]
        [HDR]_HighLightColor("Highlight Color", Color) = (0.7,0.2,0.17,1)
        
        [KeywordEnum(None, Fresnel, Depth, DoubleSideDepth)]
        _MFCel_HLight("HighLight", Float) = 0
        
        [MFKeywordRely(_MFCEL_HLIGHT_FRESNEL)]
        _HighLightFalloff("Highlight Falloff", Range(0.001, 100)) = 2
        
        [MFKeywordRely(_MFCEL_HLIGHT_DEPTH, _MFCEL_HLIGHT_DOUBLESIDEDEPTH)]
        _SampleOffset("Sample Offset", Range(0.01,1)) = 1
        
        [MFKeywordRely(_MFCEL_HLIGHT_DEPTH, _MFCEL_HLIGHT_DOUBLESIDEDEPTH)]
        _DepthThreshold("Depth Threshold", Range(0.001,0.25)) = 1
        
        /*======= Defination =======*/
        [Space(10)]
        [MFModuleDefinition(_MFCEL_STOCKING)]_Stocking("Stocking", Float) = 0
        [MFModuleDefinition(_MFCEL_FACESDF)]_Face("Face", Float) = 0
        [MFModuleDefinition(_MFCEL_HAIR)]_Hair("Hair", Float) = 0
        
        /*======= Mask Tex=======*/
        [MFPublicTex(_MFCEL_STOCKING Weave True, _MFCEL_FACESDF SDFShadow False, _MFCEL_HAIR Shifting True)]
        _MaskTex("Mask Tex", 2D) = "black" {}
        
        /*======= SDF Face =======*/
        [MFModuleElement(_Face)]
        _AngleAmp("AngleAmp", Range(-1,1)) = 0
        [MFModuleElement(_Face)]
        _FaceShadowBandwidth("Face Shadow BandWidth", Range(0,0.25)) = 0
        
        /*======= Stocking =======*/
        [MFModuleElement(_Stocking)]
        _NormalStr("NormalStr", Float) = 1.5
        
        [MFModuleElement(_Stocking)]
        _FresnelRatio("FresnelRatio", Range(0,1)) = 1
        
        [MFModuleElement(_Stocking)]
        _FresnelStart("FresnelStart", Range(0,1)) = 0.5
        
        [MFModuleElement(_Stocking)]
        [HDR]_StockingColor("StockingColor", Color) = (0,0,0,1)
        
        /*========= Hair =========*/
        [MFModuleElement(_Hair)]
        [HDR]_SpecColor1("Layer1 Color", Color) = (1,1,1,1)
        
        [MFModuleElement(_Hair)]
        [HDR]_SpecColor2("Layer2 Color", Color) = (1,1,1,1)
        
        [MFSplitVectorDrawer(_Hair, SpecMaskOffset#1#0_1 Shift#1 Layer1Offset#1#0.0001_1 Layer2Offset#1#0.0001_1)]
        _HairData("HairData", Vector) = (1,1,1,1)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            Name "Base"
            HLSLPROGRAM
            #include "Library/MFMathUtility.hlsl"
            #include "Library/MFBase.hlsl"
            #include "Library/MFCelLighting.hlsl"
            #include "Library/MFCelSkinFunc.hlsl"
            #include "Library/MFCelHairFunc.hlsl"
            #pragma shader_feature _ _MFCEL_HAIR _MFCEL_FACESDF _MFCEL_STOCKING
            #pragma shader_feature _ _MFCEL_HLIGHT_FRESNEL _MFCEL_HLIGHT_DEPTH _MFCEL_HLIGHT_DOUBLESIDEDEPTH
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma vertex vert
            #pragma fragment frag

            Texture2D _DiffuseTex;
            SamplerState sampler_DiffuseTex;

            Texture2D _NormalTex;
            SamplerState sampler_NormalTex;

            Texture2D _PBSTex;
            SamplerState sampler_PBSTex;

            Texture2D _RampTex;
            SamplerState sampler_RampTex;

            Texture2D _CameraDepthTexture;
            SamplerState sampler_CameraDepthTexture;

            float _PerspectiveCorrection;
            float _RimFadeDistance;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseTex_ST;
            float4 _BaseColor;
        
            float _SelfShadowStr;
            float _LitEdgeBandWidth;
            float _LitIndirectAtten;
            float _EnvironmentEffect;
        
            float4 _RimColor;
            float _RimFalloff;
            float4 _HighLightColor;
            float _HighLightFalloff;
            float _SampleOffset;
            float _DepthThreshold;
            
            float4 _MaskTex_ST;
        // #ifdef _MFCEL_FACESDF
            float _AngleAmp;
            float _FaceShadowBandwidth;
        // #endif
        // #ifdef _MFCEL_STOCKING
            float _NormalStr;
            float _FresnelRatio;
            float _FresnelStart;
            float4 _StockingColor;
        // #endif
        // #ifdef _MFCEL_HAIR
            float4 _SpecColor1;
            float4 _SpecColor2;
            float4 _HairData;
        // #endif
            CBUFFER_END


            #define _SpecMaskOffset _HairData.x
            #define _Shift _HairData.y
            #define _Layer1Offset _HairData.z
            #define _Layer2Offset _HairData.w



            MFLightData EditLightingData(MFLightData ld, float2 uv, out float editLightAtten)
            {
                ld.shadowAtten = ld.shadowAtten * _SelfShadowStr + 1 - _SelfShadowStr;
                #ifdef _MFCEL_FACESDF
                ld.lightAtten = SDFFace(ld.lightDir, -unity_ObjectToWorld._m20_m21_m22, uv, _AngleAmp, _FaceShadowBandwidth);
                #endif
                editLightAtten = ld.lightAtten / _LitEdgeBandWidth + _LitEdgeBandWidth;
                editLightAtten = smoothstep(0,1,editLightAtten);
                editLightAtten = lerp(0, editLightAtten, _LitIndirectAtten);
                return ld;
            }
            
            void MFCelRampLight(BaseVarying i, MFMatData matData, MFLightData lightData, out float3 diffuse, out float3 specular, out float3 GI)
            {
                float shadow = CelShadow(i.posWS, i.normalWS, lightData.lightDir, lightData.shadowAtten);

                diffuse = matData.diffuse;
                #ifdef _MFCEL_STOCKING
                MFStockingAttributes mfsa;
                mfsa.tilling = _MaskTex_ST;
                mfsa.normalStr = _NormalStr;
                mfsa.falloff = _RimFalloff;
                mfsa.fStart = _FresnelStart;
                mfsa.fRatio = _FresnelRatio;
                mfsa.color = _StockingColor;
                mfsa.rimColor = _RimColor;
                diffuse = StockingDiffuse(diffuse, i.uv, matData, lightData, mfsa);
                #endif

                #ifdef _MFCEL_HAIR
                MFCelHairAttributes hairAttr;
                hairAttr.specMaskOffset = _SpecMaskOffset;
                hairAttr.shift = _Shift;
                hairAttr.layerOffset = float2(_Layer1Offset, _Layer2Offset);
                hairAttr.specColor1 = _SpecColor1;
                hairAttr.specColor2 = _SpecColor2;
                float shiftTex = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw);
                specular = HairLighting(hairAttr, normalize(i.tangentWS), normalize(i.normalWS), normalize(lightData.lightDir), normalize(matData.viewDirWS), i.uv.xy, 1 - matData.roughness, shiftTex);
                #else
                specular = GetSpecular(i.normalWS, matData, lightData);
                #endif
                GI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);
            }

            void Rim(inout float4 color, MFMatData matData, MFLightData lightData)
            {
                half rim =saturate(pow(saturate(1-matData.ndv), _RimFalloff));
                color.rgb = lerp(color.rgb, color.rgb * _RimColor, saturate(rim) * _RimColor.a * (1-lightData.lightAtten ));
            }
            void StaticLight(inout float3 color, MFMatData matData)
            {
                half staticatten = dot(matData.normalWS.xyz, normalize(-cross(normalize(matData.viewDirWS),UNITY_MATRIX_V[1])));
                half3 staticLight = Curve(Smootherstep01(staticatten), max(0.001, _HighLightFalloff)) * _HighLightColor;
                color += staticLight;
            }
            void StaticLight(inout float3 color, BaseVarying i)
            {
                float4 clipPos = TransformWorldToHClip(i.posWS);
                float4 screenPos = ComputeScreenPos(clipPos);
                screenPos.xy /= screenPos.w;
                float screenDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos.xy + half2(_SampleOffset * 0.01, 0)), _ZBufferParams);
                float selfDepth = screenPos.w;
                float depthDelta = saturate((screenDepth - selfDepth));
                depthDelta = depthDelta > _DepthThreshold;
                half3 staticLight = depthDelta * _HighLightColor.rgb;
                color = lerp(color, staticLight, depthDelta * _HighLightColor.a);
            }
            void StaticLight(inout float3 color, BaseVarying i, float3 viewDir, float3 lightDir)
            {
                float4 clipPos = TransformWorldToHClip(i.posWS);
                float4 screenPos = ComputeScreenPos(clipPos);
                screenPos.xy /= screenPos.w;
                float2 screenDepth = 0;
                float fade = saturate(1 - screenPos.w / _RimFadeDistance);
                float offset = _SampleOffset * lerp(1, fade, _PerspectiveCorrection);
                screenDepth.x = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos.xy + half2(offset * 0.01, 0)), _ZBufferParams);
                screenDepth.y = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos.xy - half2(offset * 0.01, 0)), _ZBufferParams);
                float selfDepth = screenPos.w;
                float2 depthDelta = linearstep(clamp(screenDepth - selfDepth, 0, _DepthThreshold), 0, _DepthThreshold);
                float VdL = dot(-viewDir, -lightDir);
                depthDelta.x *= VdL * 0.45 + 0.55;
                depthDelta.y *= (- VdL) * 0.45 + 0.55;
                float2 delta = max(depthDelta.x, depthDelta.y);
                float avg = (delta.x + delta.y) * 0.5;
                color = lerp(color, avg * _HighLightColor.rgb, avg * _HighLightColor.a * fade);
            }
            half4 frag (BaseVarying i) : SV_Target
            {
                float2 realUV = i.uv * _BaseTex_ST.xy + _BaseTex_ST.zw;
                float4 diffuseTex = SAMPLE_TEXTURE2D(_DiffuseTex, sampler_DiffuseTex, realUV);
                float4 normalTex = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, realUV);
                float4 pbsTex = SAMPLE_TEXTURE2D(_PBSTex, sampler_PBSTex, realUV);
                MFMatData matData = GetMatData(i, diffuseTex.rgb * _BaseColor, diffuseTex.a, normalTex.rg, pbsTex.r, pbsTex.g, pbsTex.b, normalTex.b);
                MFLightData ld = GetLightingData(i, matData);
                float editAtten;
                ld = EditLightingData(ld, i.uv, editAtten);
                
                float3 diffuse;
                float3 specular;
                float3 GI;
                MFCelRampLight(i, matData, ld, diffuse, specular, GI);  
                float4 color = matData.alpha;
                color.rgb = diffuse * lerp(1, GI, _EnvironmentEffect);
                
                Rim(color, matData, ld);
                
                color.rgb += specular + diffuse * ld.lightAtten * ld.lightColor * SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(ld.lightAtten, _LitEdgeBandWidth));
                #ifdef _MFCEL_HLIGHT_FRESNEL
                StaticLight(color.rgb, matData);
                #elif _MFCEL_HLIGHT_DEPTH
                StaticLight(color.rgb, i);
                #elif _MFCEL_HLIGHT_DOUBLESIDEDEPTH
                StaticLight(color.rgb, i, ld.lightDir, UNITY_MATRIX_V[0]);
                #endif
                
                return color;
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "MFCelShaderGUI"
}
