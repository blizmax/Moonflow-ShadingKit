Shader"Moonflow/BaseLight"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _DiffuseTex ("Diffuse Tex", 2D) = "white" {}
        _NormalTex("Normal Tex", 2D) = "bump" {}
        _PBSTex("Data Tex", 2D) = "black" {}
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
            // #include "Library/MFCelGI.hlsl"
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
                UNITY_DEFINE_INSTANCED_PROP(float4, _DiffuseTex_ST)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _ShadowStr)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

            half4 frag (BaseVarying i) : SV_Target
            {
                //MFMatData
                MFMatData matData = GetMatData(i, _DiffuseTex, sampler_DiffuseTex, _NormalTex, sampler_NormalTex, _PBSTex, sampler_PBSTex, _DiffuseTex_ST);
                MFLightData ld = GetLightingData(i, matData);

                float3 diffuse;
                float3 specular;
                float3 GI;
                MFBaseCelLight(i, matData, ld, diffuse, specular, GI);

                float4 color = matData.alpha;
                color.rgb = diffuse + specular + GI;
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
