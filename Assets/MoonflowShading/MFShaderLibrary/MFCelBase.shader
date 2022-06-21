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
        
        /*======= Mask Tex=======*/
        [MFPublicTex(_MFCEL_STOCKING Weave True, _MFCEL_FACESDF SDFShadow False)]
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
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            Name "Base"
            HLSLPROGRAM
            #include "Library/MFBase.hlsl"
            #include "Library/MFCelLighting.hlsl"
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

            Texture2D _MaskTex;
            SamplerState sampler_MaskTex;

            Texture2D _CameraDepthTexture;
            SamplerState sampler_CameraDepthTexture;

            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BaseTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
            
                UNITY_DEFINE_INSTANCED_PROP(float, _SelfShadowStr)
                UNITY_DEFINE_INSTANCED_PROP(float, _LitEdgeBandWidth)
                UNITY_DEFINE_INSTANCED_PROP(float, _LitIndirectAtten)
                UNITY_DEFINE_INSTANCED_PROP(float, _EnvironmentEffect)
            
                UNITY_DEFINE_INSTANCED_PROP(float4, _RimColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _RimFalloff)
                UNITY_DEFINE_INSTANCED_PROP(float4, _HighLightColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _HighLightFalloff)
                UNITY_DEFINE_INSTANCED_PROP(float, _SampleOffset)
                UNITY_DEFINE_INSTANCED_PROP(float, _DepthThreshold)
            
                UNITY_DEFINE_INSTANCED_PROP(float4, _MaskTex_ST)
            
                UNITY_DEFINE_INSTANCED_PROP(float, _AngleAmp)
                UNITY_DEFINE_INSTANCED_PROP(float, _FaceShadowBandwidth)
            
                UNITY_DEFINE_INSTANCED_PROP(float, _NormalStr)
                UNITY_DEFINE_INSTANCED_PROP(float, _FresnelRatio)
                UNITY_DEFINE_INSTANCED_PROP(float, _FresnelStart)
                UNITY_DEFINE_INSTANCED_PROP(float3, _StockingColor)
            
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

            float3 CelColorMix(float3 color1, float3 color2)
            {
                return max(color1, color2) * min(color1, color2);
            }
            float3 CelColorGradient(float3 color1, float3 color2, float per)
            {
                return lerp(color1, color2, per) + CelColorMix(color1, color2) * saturate( 1-abs(per * 2 - 1));
            }

            float SDFFace(float3 lightDir, float3 forward, float2 uv)
            {
                float LR = cross(forward, -lightDir).y;
                // 左右翻转
                float2 flipUV = float2(1 - uv.x, uv.y);
                float lightMapL = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv).r;
                float lightMapR = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, flipUV).r;

                float lightMap = LR < 0 ? lightMapL : lightMapR;
                lightDir.y = 0;
                forward.y = 0;
                float s = saturate(dot(-lightDir, forward) + _AngleAmp);
                return saturate(smoothstep(1-lightMap - _FaceShadowBandwidth , 1-lightMap + _FaceShadowBandwidth, s ));
            }

            half Fabric(half NdV)
            {
                half intensity = 1 - NdV;
                intensity = 0 - (intensity * 0.4 - pow(intensity, _RimFalloff) ) * 0.35;
                return saturate(intensity);
            }
            half StockingAlpha(half weavingMask, half NdV, half2 uv)
            {
                half rNdV = NdV * NdV;
                half rim = saturate(((1 - clamp(rNdV, 0, 1) ) * _FresnelRatio + _FresnelStart));
                rim = clamp(rim,0, 1);
                half mask = rNdV * weavingMask;
                mask = rim - mask * rim;
                return saturate(mask);
            }
            
            float3 Curve(float3 color, float k)
            {
	            return exp(log(max(color, int3(0, 0, 0))) * k);
            }

            float3 StockingDiffuse(float3 baseColor, float2 uv, MFMatData matData, MFLightData lightData)
            {
                half weaveMask = max(0, SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv * _MaskTex_ST.xy + _MaskTex_ST.zw) * _NormalStr);
                half shade = lerp(0, lightData.NdL * 0.5 + 0.5, lightData.shadowAtten);
                half stockingFabric = Fabric(matData.ndv) * clamp(shade, 0.5, 1);
                half stockingAlpha = StockingAlpha(weaveMask, matData.ndv, uv);
                half highlight = saturate(1-stockingAlpha) * half4(Curve(matData.ndv.xxx,15),1);
                baseColor = baseColor * (1-stockingAlpha)+_StockingColor * stockingAlpha + highlight*0.05;
                return lerp(baseColor, _RimColor, saturate(stockingFabric));
            }
            
            MFLightData EditLightingData(MFLightData ld, float2 uv)
            {
                ld.shadowAtten = ld.shadowAtten * _SelfShadowStr + 1 - _SelfShadowStr;
                #ifdef _MFCEL_FACESDF
                ld.lightAtten = SDFFace(ld.lightDir, -unity_ObjectToWorld._m20_m21_m22, uv);
                #endif
                ld.lightAtten = ld.lightAtten / _LitEdgeBandWidth + _LitEdgeBandWidth;
                ld.lightAtten = smoothstep(0,1,ld.lightAtten);
                ld.lightAtten = lerp(0, ld.lightAtten, _LitIndirectAtten);
                return ld;
            }


            // float3 HairLighting (float3 tangent, float3 normal, float3 lightVec, 
            //          float3 viewVec, float2 uv, float smoothness, float shiftTex)
            // {
            //     float3 bitangent = -normalize(cross(tangent, normal));
            //     // shift tangents
            //     shiftTex *= _SpecMaskOffset;
            //     float3 t1 = ShiftTangent(bitangent, normal, /*primaryShift*/_Shift + shiftTex);
            //     float3 t2 = ShiftTangent(bitangent, normal, /*secondaryShift*/_Shift + shiftTex) ;
            //
            //     // diffuse lighting
            //     smoothness = saturate(smoothness - 0.3);
            //     // specular lighting
            //     // add second specular term
            //     float3 specular = _SpecColor1 * StrandSpecular(t1, viewVec, lightVec, 0.1/_Layer1Offset) * _Layer1Intensity;
            //     specular += _SpecColor2 * StrandSpecular(t2, viewVec, lightVec, 0.1/_Layer2Offset) * _Layer2Intensity;
            //     
            //     // Final color
            //     // float3 o;
            //     // o.rgb = (diffuse + specular) * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv); /** lightColor*/;
            //     // o.rgb *= ambOcc; 
            //     // o.a = tex2D(tAlpha, uv);
            //
            //     return specular;
            // }

            void MFCelRampLight(BaseVarying i, MFMatData matData, MFLightData lightData, out float3 diffuse, out float3 specular, out float3 GI)
            {
                float shadow = CelShadow(i.posWS, i.normalWS, lightData.lightDir, lightData.shadowAtten);

                diffuse = matData.diffuse;
                #ifdef _MFCEL_STOCKING
                diffuse = StockingDiffuse(diffuse, i.uv, matData, lightData);
                #endif

                // #ifdef _MFCEL_HAIR
                float shiftTex = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv * _MaskTex_ST.xy + _MaskTex_ST.zw);
                // float3 hairSpecColor = HairLighting(normalize(i.tangentWS), normalize(i.normalWS), normalize(lightData.lightDir), normalize(matData.viewDirWS), i.uv.xy, 1 - matData.roughness, shiftTex);
                // #else
                specular = GetSpecular(i.normalWS, matData, lightData);
                // #endif
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
                screenDepth.x = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos.xy + half2(_SampleOffset * 0.01, 0)), _ZBufferParams);
                screenDepth.y = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos.xy - half2(_SampleOffset * 0.01, 0)), _ZBufferParams);
                float selfDepth = screenPos.w;
                float2 depthDelta = saturate(screenDepth - selfDepth)> _DepthThreshold;
                float VdL = dot(-viewDir, -lightDir);
                depthDelta.x *= VdL * 0.45 + 0.55;
                depthDelta.y *= (- VdL) * 0.45 + 0.55;
                float delta = max(depthDelta.x, depthDelta.y);
                color = lerp(color, delta * _HighLightColor.rgb, delta * _HighLightColor.a);
            }
            half4 frag (BaseVarying i) : SV_Target
            {
                float2 realUV = i.uv * _BaseTex_ST.xy + _BaseTex_ST.zw;
                float4 diffuseTex = SAMPLE_TEXTURE2D(_DiffuseTex, sampler_DiffuseTex, realUV);
                float4 normalTex = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, realUV);
                float4 pbsTex = SAMPLE_TEXTURE2D(_PBSTex, sampler_PBSTex, realUV);
                MFMatData matData = GetMatData(i, diffuseTex.rgb * _BaseColor, diffuseTex.a, normalTex.rg, pbsTex.r, pbsTex.g, pbsTex.b, normalTex.b);
                
                MFLightData ld = GetLightingData(i, matData);
                
                ld = EditLightingData(ld, i.uv);
                
                float3 diffuse;
                float3 specular;
                float3 GI;
                MFCelRampLight(i, matData, ld, diffuse, specular, GI);
                float4 color = matData.alpha;
                color.rgb = diffuse * lerp(1, GI, _EnvironmentEffect);
                
                Rim(color, matData, ld);
                
                color.rgb += specular + diffuse * ld.lightAtten * ld.lightColor;
                
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
