Shader"Moonflow/MFCelHair"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex ("Normal", 2D) = "bump" {}
        _NormalStr ("NormalStr", Range(0,2)) = 1
        _HighlightShiftTex("HighlightTex", 2D) = "black" {}
        _EnvironmentEffect("EnvironmentEffect", Range(0,1)) = .2
        _Metallic("Metallic", Range(0,1)) = 0.5
        [HDR]_SpecColor1("SpecColor1", Color) = (1,1,1,1)
        [HDR]_SpecColor2("SpecColor1", Color) = (1,1,1,1)
        _Shift("Shift", Float) = 0.5
        _Layer1Offset("Layer1Offset", Range(0.001,1)) = 0.5
        _Layer2Offset("Layer2Offset",  Range(0.001,1)) = 0.5
        _Layer1Intensity("Layer1Intensity", Float) = 1
        _Layer2Intensity("Layer2Intensity", Float) = 1
        _SpecMaskOffset("SpecMaskOffset", Range(0,1)) = 0.5
        _CubeIntensity("CubeIntensity", Float) = 1
        [HideInInspector]_StencilRef("Stencil Ref", Float) = 1
        [Toggle(_UV2_ON)]_UV2("UV2", Float) = 1
        
        [Header(Outline)]
        [Toggle]_MFOutlineModelStrength("Str(vertex color B channel)", Float) = 0
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "LightMode" = "UniversalForward"
        }
        LOD 100

        Pass
        {
            stencil
            {
                Ref [_StencilRef]
                Comp Always
                Pass Replace
            }
            ZWrite On
            
            HLSLPROGRAM
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma shader_feature _ _UV2_ON
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"
            #include "Old/MFPBRFunction.hlsl"



            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
                float2 hairSpecUV : TEXCOORD2;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 positionOS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float4 shadowCoord : TEXCOORD5;
                float3 vertexSH : TEXCOORD6;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            Texture2D _NormalTex;
            SamplerState sampler_NormalTex;
            Texture2D _SPColorTex;
            SamplerState sampler_SPColorTex;
            Texture2D _HighlightShiftTex;
            SamplerState sampler_HighlightShiftTex;
            // TextureCube _CubeMap;
            // SamplerState sampler_CubeMap;

            CBUFFER_START(UnityPerMaterial)
            float4 _HighlightShiftTex_ST;
            half4 _SpecColor1;
            half4 _SpecColor2;
            half4 _Color;
            half _NormalStr;
            half _Shift;
            half _SpecBalance;
            half _Metallic;
            half _SpecMaskOffset;
            half _Layer1Offset;
            half _Layer2Offset;
            half _Layer1Intensity;
            half _Layer2Intensity;
            half _CubeIntensity;
            half _EnvironmentEffect;
            CBUFFER_END

            float3 ColorCurveMapping(float3 color, float k)
            {
	            return exp(log(max(color, int3(0, 0, 0))) * k);
            }
            float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
            {
                float3 H = normalize(L + V);
                float dotTH = dot(T, H);
                float sinTH = sqrt(1.0 - dotTH * dotTH);
                sinTH =  ColorCurveMapping(sinTH, exponent);
                float dirAtten = smoothstep(-1, 0, saturate(dotTH+1));
                return saturate(dirAtten * sinTH);
            }
            float LegacySpecular(float3 T, float3 V, float3 N,float exponent)
            {
                // float3 H = normalize(L + V);
                float dotTH = dot(T, V);
                float result = dot(V, cross(T, N));
                result =  ColorCurveMapping(result, exponent);
                float dirAtten = smoothstep(-1, 0, saturate(dotTH+1));
                return saturate(dirAtten * result);
            }


            float3 HairLighting (float3 tangent, float3 normal, float3 lightVec, 
                     float3 viewVec, float2 uv, float smoothness, float shiftTex)
            {
                float3 bitangent = -normalize(cross(tangent, normal));
                // shift tangents
                shiftTex *= _SpecMaskOffset;
                float3 t1 = ShiftTangent(bitangent, normal, /*primaryShift*/_Shift + shiftTex);
                float3 t2 = ShiftTangent(bitangent, normal, /*secondaryShift*/_Shift + shiftTex) ;
            
                // diffuse lighting
                smoothness = saturate(smoothness - 0.3);
                // specular lighting
                // add second specular term
                float3 specular = _SpecColor1 * StrandSpecular(t1, viewVec, lightVec, 0.1/_Layer1Offset) * _Layer1Intensity;
                specular += _SpecColor2 * StrandSpecular(t2, viewVec, lightVec, 0.1/_Layer2Offset) * _Layer2Intensity;
                
                // Final color
                // float3 o;
                // o.rgb = (diffuse + specular) * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv); /** lightColor*/;
                // o.rgb *= ambOcc; 
                // o.a = tex2D(tAlpha, uv);

                return specular;
            }

            half3 MobileComputeMixingWeight(half3 IndirectIrradiance, half AverageBrightness, half Roughness)
	        {
		        half MixingAlpha = smoothstep(0, 1, saturate(Roughness /* View.ReflectionEnvironmentRoughnessMixingScaleBiasAndLargestWeight.x + View.ReflectionEnvironmentRoughnessMixingScaleBiasAndLargestWeight.y*/));
		        half3 MixingWeight = IndirectIrradiance / max(AverageBrightness, .0001f);
		        MixingWeight = min(MixingWeight, 1/*View.ReflectionEnvironmentRoughnessMixingScaleBiasAndLargestWeight.z*/);
		        return lerp(1.0f, MixingWeight, MixingAlpha);
	        }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.positionOS = v.vertex;
                o.positionCS = TransformObjectToHClip(v.vertex);
                #ifdef _UV2_ON
                o.uv = float4(v.uv, v.hairSpecUV);
                #else
                o.uv = float4(v.uv, v.uv);
                #endif
                VertexPositionInputs position_inputs = GetVertexPositionInputs(v.vertex);
                VertexNormalInputs normal_inputs = GetVertexNormalInputs(v.normal, v.tangent);
                o.normalWS = normal_inputs.normalWS;
                o.tangentWS = normal_inputs.tangentWS;
                o.bitangentWS = normal_inputs.bitangentWS;
                o.shadowCoord = GetShadowCoord(position_inputs);
                o.vertexSH = SampleSHVertex(o.normalWS);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 positionWS = TransformObjectToWorld(i.positionOS);
                half3 viewDirWS = GetCameraPositionWS() - positionWS;
                
                half3 normalTexTS = normalize(UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, i.uv.zw)));
                half3 normalWorld = TransformTangentToWorld(normalTexTS.xyz,
        half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz));
                normalWorld = normalize(normalWorld);
                
                half3 cameraVector = -viewDirWS;
                float4 MSRO = SAMPLE_TEXTURE2D(_SPColorTex, sampler_SPColorTex, i.uv.zw);

                Light mainLight = GetMainLight(i.shadowCoord);
                float shiftTex = SAMPLE_TEXTURE2D(_HighlightShiftTex, sampler_HighlightShiftTex, i.uv.xy * _HighlightShiftTex_ST.xy + _HighlightShiftTex_ST.zw);
                float3 hairSpecColor = HairLighting(normalize(i.tangentWS), normalize(normalWorld), normalize(mainLight.direction), normalize(viewDirWS), i.uv.xy, 1-MSRO.b, shiftTex);
                // return half4(normalize(i.tangentWS), 1);
                float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.zw) * _Color;
                float metallic = _Metallic * MSRO.r;
                float3 diffuse = albedo - albedo * metallic;

                 half3 diffuseGI = SAMPLE_GI(input.lightmapUV, i.vertexSH, i.normalWS);
                float3 col = 0;
                float NoL = dot( normalWorld, mainLight.direction );
                NoL = max(0, NoL);
                col += albedo * lerp(1, diffuseGI, _EnvironmentEffect) /** MSRO.b*/;
                half3 lightEffectedColor = NoL * mainLight.color;
                #ifdef _ADDITIONAL_LIGHTS
                for (uint index = 0u; index < GetAdditionalLightsCount() ; ++index)
                {
                    Light addLight = GetAdditionalLight(index , positionWS);
                    lightEffectedColor = max(lightEffectedColor, addLight.distanceAttenuation * addLight.shadowAttenuation * addLight.color * diffuse * max(0, dot(normalWorld, normalize(addLight.direction))) * saturate(addLight.distanceAttenuation));
                }
                #endif
                col += lightEffectedColor * (diffuse + hairSpecColor);
                
                half3 reflectDir = reflect(cameraVector, i.normalWS);
                half roughness = PerceptualSmoothnessToPerceptualRoughness(MSRO.b);
                half mip = PerceptualRoughnessToMipmapLevel(roughness);
                // half4 cubeTex = SAMPLE_TEXTURECUBE_LOD(_CubeMap, sampler_CubeMap, normalize(reflectDir), mip);
                half3 cubeColor = GetImageBasedReflectionLighting(MSRO.b, MSRO.a * Luminance(SampleSH(normalWorld)), normalize(reflectDir), normalWorld);
                col += cubeColor * max(0, _CubeIntensity) * MSRO.g;
                return half4(saturate(col), 1);
            }
            ENDHLSL
        }
        Pass
        {
            Name "Outline"
            Tags{"LightMode" = "Outline"}

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex OutlineVertex
            #pragma fragment OutlineFragment
            #include "Old/MFOutline.hlsl"

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
