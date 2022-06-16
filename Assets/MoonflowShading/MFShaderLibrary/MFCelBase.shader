Shader"Moonflow/CelBase"
{
    Properties
    {
        _BaseColor("Color", Color) = (1,1,1,1)
        _DiffuseTex ("Diffuse Tex", 2D) = "white" {}
        _NormalTex("Normal Tex", 2D) = "bump" {}
        _PBSTex("Data Tex", 2D) = "black" {}
        _BaseTex_ST("TileOffset", Vector) = (1,1,0,0)
        
        _SelfShadowStr("Self Shadow Str", Range(0,1)) = 0.75
        _LitEdgeBandWidth("Lit Edge BandWidth", Range(0.001,1))=0.15
        _LitIndirectAtten("Lit Indirect Atten",Range(0,1)) = 0.5
        _EnvironmentEffect("EnvironmentEffect", Range(0,1)) = .2
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "Base"
            HLSLPROGRAM
            #include "Library/MFBase.hlsl"
            #include "Library/MFCelLighting.hlsl"
            #include "Library/MFCelGI.hlsl"
            #pragma shader_feature MF_CEL_NORMALTEX
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

            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BaseTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
            
                UNITY_DEFINE_INSTANCED_PROP(float, _SelfShadowStr)
                UNITY_DEFINE_INSTANCED_PROP(float, _LitEdgeBandWidth)
                UNITY_DEFINE_INSTANCED_PROP(float, _LitIndirectAtten)
                UNITY_DEFINE_INSTANCED_PROP(float, _EnvironmentEffect)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

            float3 CelColorMix(float3 color1, float3 color2)
            {
                return max(color1, color2) * min(color1, color2);
            }
            float3 CelColorGradient(float3 color1, float3 color2, float per)
            {
                return lerp(color1, color2, per) + CelColorMix(color1, color2) * saturate( 1-abs(per * 2 - 1));
            }

            MFLightData EditLightingData(MFLightData ld)
            {
                ld.shadowAtten = ld.shadowAtten * _SelfShadowStr + 1 - _SelfShadowStr;
                ld.lightAtten = ld.lightAtten / _LitEdgeBandWidth + _LitEdgeBandWidth;
                // ld.lightAtten = saturate(ld.lightAtten);
                ld.lightAtten = smoothstep(0,1,ld.lightAtten);
                // ld.lightAtten = smoothstep(0, _LitEdgeBandWidth,ld.lightAtten)/**0 .5*/;
                ld.lightAtten = lerp(0, ld.lightAtten, _LitIndirectAtten);
                return ld;
            }

            void MFCelRampLight(BaseVarying i, MFMatData matData, MFLightData lightData, out float3 diffuse, out float3 specular, out float3 GI)
            {
                float shadow = CelShadow(i.posWS, i.normalWS, lightData.lightDir, lightData.shadowAtten);

                diffuse = matData.diffuse;
                specular = GetSpecular(i.normalWS, matData, lightData);
                GI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS);
            }

            
            half4 frag (BaseVarying i) : SV_Target
            {
                float2 realUV = i.uv * _BaseTex_ST.xy + _BaseTex_ST.zw;
                float4 diffuseTex = SAMPLE_TEXTURE2D(_DiffuseTex, sampler_DiffuseTex, realUV);
                float4 normalTex = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, realUV);
                float4 pbsTex = SAMPLE_TEXTURE2D(_PBSTex, sampler_PBSTex, realUV);
                
                //MFMatData
                MFMatData matData = GetMatData(i, diffuseTex.rgb * _BaseColor, diffuseTex.a, normalTex.rg, pbsTex.r, pbsTex.g, pbsTex.b, normalTex.b);
                MFLightData ld = GetLightingData(i, matData);
                
                ld = EditLightingData(ld);
                
                float3 diffuse;
                float3 specular;
                float3 GI;
                MFCelRampLight(i, matData, ld, diffuse, specular, GI);
                // return half4(CelColorGradient(GI, diffuseTex.rgb, ld.lightAtten),1);
                float4 color = matData.alpha;
                color.rgb = diffuse * lerp(1, GI, _EnvironmentEffect) + specular;
                color.rgb += diffuse * ld.lightAtten * ld.lightColor * ld.shadowAtten;
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
}
