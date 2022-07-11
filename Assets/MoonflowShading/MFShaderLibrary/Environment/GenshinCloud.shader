Shader"Test/GenshinCloud"
{
    Properties
    {
        _Tex0 ("Noise", 2D) = "white" {}
        _Tex1 ("Mask", 2D) = "white"{}
        
        _CameraPlanarPos("Camera Planar Pos",Vector) = (0,0,-46.00281,0)
        _CloudLightDir("Cloud Light Dir",Vector) = (0,1,0,0)
        _cb0_7("7",Color) = (0.02719, 0.05757, 0.18782, 0)
        _cb0_8("8",Color) = (0.01329, 0.04425, 0.18125, 0)
        _cb0_9("9",Color) = (0.0687, 0.24619, 0.45641, 0)
        _cb0_10("10",Color) = (0.04328, 0.29054, 0.6398, 0.50569)
        _unknownStr0("unknown Str 0", Float) = 0.40979
        _unknownColor0("Unknown Color 0", Color) = (0.34851, 0.74134, 1, 1)
        _unknownIntensity0("Unknown Intensity 0", Float) = 1.24741
        _unknownStr1("Unknown Str 1", Float) = 0.49728
        _unknownUnnormalizedDir0("Unknown Unnormalized Dir 0", Vector) = (-0.67019, 0.50162, 0.54701, 0)
        _cb0_16("16",Color) = (1, 0.99262, 0.86738, 9.92669)
        _cb0_17("17",Vector) = (0, 0, 1, 999.37653)
        _cb0_18("18",Color) = (0.70543, 0.76732, 0.76504, 0.50917)
        _unknownColorStr0("Unknown Color Str 0", Float) = 0.50917
        _unknownUnnormalizedDir1("Unknown Unnormalized Dir 1", Vector) = (0.46066, -0.71634, 0.52406, 0)
        _cb0_20("20",Color) = (0.15648, 0.18993, 0.26669, 0.03339)
        _cb0_21("21",Vector) = (0.00213, 0.627, 24.44967, 0)
        _BrightColor0("亮部混合0",Color) = (1, 0.89974, 0.7816, 0)
        _BrightColor1("亮部混合1",Color) = (1, 0.89974, 0.7816, 0)
        _DarkColor0("暗部混合0",Color) = (0, 0.27366, 0.45641, 0)
        _DarkColor1("暗部混合1",Color) = (0, 0.40506, 1, 0)
        _cb0_27("27",Vector) = (0, 0, 0.11, 1)
        _CloudIntensity("整体亮度", Float) = 1
        _GridNum("贴图行列数量(一行z个,一列w个)", Vector) = (2,4,0,0)
        _DissolveScale("溶解缩放", Float) = 3
        _DissolveStr("溶解强度", Range(0, 0.2)) = 0.015
        _DissolveSpeed("溶解滚动速度", Float) = 6
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
//            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float4 tl46: TEXCOORD1;
                float4 color : COLOR;//粒子系统CustomData覆盖，x是bool，y未知0-1去间值，zw恒为0.09804
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 v1_mayCenterScreenPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 v3 : TEXCOORD2;
                float4 v4 : TEXCOORD3;
                float3 v5_SkyColor : TEXCOORD4;
                float3 v6_cb0_16Color : TEXCOORD5;
                float3 v7_noiseGColor : TEXCOORD6;
                float3 v8_unknownColor : TEXCOORD7;
                float3 v9_unknownColor : TEXCOORD8;
                float4 temp: TEXCOORD9;
            };

            Texture2D _Tex0;
            SamplerState sampler_Tex0;
            Texture2D _Tex1;
            SamplerState sampler_Tex1;

            float4 _CameraPlanarPos;
            float4 _CloudLightDir;
            float4 _cb0_7;
            float4 _cb0_8;
            float4 _cb0_9;
            float4 _cb0_10;
            float _unknownStr0;
            float3 _unknownColor0;
            float _unknownIntensity0;
            float _unknownStr1;
            float3 _unknownUnnormalizedDir0;
            
            float4 _cb0_16;
            float4 _cb0_17;
            float4 _cb0_18;
            float3 _unknownUnnormalizedDir1;
            float4 _cb0_20;
            float4 _cb0_21;
            float4 _BrightColor0;
            float4 _BrightColor1;
            float4 _DarkColor0;
            float4 _DarkColor1;
            float4 _cb0_27;
            float _CloudIntensity;
            float4 _GridNum;
            float _DissolveStr;
            float _DissolveScale;
            float _DissolveSpeed;

            float smoothstep(float input)
            {
                return (3 - input * 2) * input * input;
            }
            float linearstep(float x, float min, float max)
            {
                return (x - min) / (max - min);
            }
            float2 linearstep(float2 xy, float min, float max)
            {
                return (xy - min.xx) / (max - min);
            }

            v2f vert (appdata v)
            {
                float4 tl46 = v.tl46;
                tl46 = float4(233.20918, 26.16353, 0.4, 0.6);
                v2f o;
                o.temp = float4(0,0,0,0);
                
                float4 r0;
                float4 r1;
                o.vertex = TransformObjectToHClip(v.vertex);
                float3 posWS = TransformObjectToWorld(v.vertex);
                r1.xyz = o.vertex;
                
                float4 r2 = 0;
                float3 worldDir = posWS - /*_WorldSpaceCameraPos*/_CameraPlanarPos.xyz;
                float4 halfPosCS = o.vertex * 0.5;
                o.v1_mayCenterScreenPos = float4(halfPosCS.x + halfPosCS.z, halfPosCS.y * _ProjectionParams.x + halfPosCS.z, 0, o.vertex.z);

                //========== 云的序号 ============
                r0.w = round((_GridNum.x * _GridNum.y - 1) * v.color.y + 0.5);
                r1.x = r0.w * _GridNum.x;
                r1.x = (r1.x > 0 ? 1 : -1) * _GridNum.x;
                r1.y = 1 / r1.x * r0.w;
                r2.y = round(r0.w / _GridNum.x);
                r2.x = frac(r1.y) * r1.x;
                //r2.xy决定是贴图上的哪朵云
                float2 SingleCloudUV = r2.xy + v.uv.xy;
                o.uv.xy = SingleCloudUV / _GridNum.xy;
                
                //========== uv扰动计算 ============
                float2 uvOffset = float2(1.2, _DissolveSpeed) * float2(_DissolveSpeed, 0.8) * _Time.x /** _cb0_21.z*/;
                o.uv.zw = v.uv.xy * _DissolveScale + uvOffset;

                //========== viewDir + 未知alpha系数 =========
                float3 viewDir = normalize(worldDir);
                float vdl = dot(_CloudLightDir.xyz, viewDir);
                float clampedVdL = clamp(vdl, -1, 1);
                float unknown_Radian = ((-0.0187 * abs(clampedVdL) + 0.0743) * abs(clampedVdL) - 0.2121) * abs(clampedVdL) + PI * 0.5;
                float sqrtVertical = sqrt(1 - abs(clampedVdL));//接近垂直时为1，接近平行为0
                float lightSide = clampedVdL > 0;
                r0.w = (unknown_Radian * sqrtVertical - lightSide - PI * 0.5) * PI * 0.2;
                r0.w = lightSide;//临时加的
                o.v3 = float4(viewDir, r0.w);
                
                r1.z = tl46.y / max(tl46.x, 0) * _cb0_27.w;
                r1.y = 1 - smoothstep(saturate(linearstep(r1.z, tl46.w, 1)));
                r1.z = smoothstep(saturate(1 / tl46.z * r1.z));

                o.v4.w = -r1.z * r1.y + 1;
                float vdu1 = dot(viewDir, _unknownUnnormalizedDir0.xyz);
                float vdu2 = dot(viewDir, _unknownUnnormalizedDir1.xyz);
                float packedVdU1 = vdu1 * 0.5 + 0.5;
                o.v4.x = packedVdU1 * _CloudIntensity;
                o.v4.yz = v.color.zw;
                o.temp.xy = float2(vdu1, vdu2);
                float strengthedNoneNegativeVdU1= max(lerp(vdu1, 1, _cb0_10.w), 0);
                r1.y = max(lerp(vdu1, 1, _DarkColor1.w), 0);
                float powedNoneNegativeVdU1 = pow(strengthedNoneNegativeVdU1, 3);
                float3 mixedColor9_10 = lerp(_cb0_9.xyz, _cb0_10.xyz, powedNoneNegativeVdU1);
                float4 r3;
                float3 mixedColor7_8 = lerp(_cb0_7.xyz, _cb0_8.xyz, powedNoneNegativeVdU1);
                
                float colorMix1 = LOAD_TEXTURE2D_X(_Tex0, float2(abs(r0.w)/max(_unknownStr0, 0.0001), 0.5)).x;
                float3 mixedColor7_8_9_10 = lerp(mixedColor9_10, mixedColor7_8, colorMix1);
                float colorStrength1 = LOAD_TEXTURE2D_X(_Tex0, float2(abs(r0.w)/max(_unknownStr1, 0.0001), 0.5)).x;
                float3 unknownColor = _unknownColor0.xyz * _unknownIntensity0.x * colorStrength1;
                
                r0.z = smoothstep(saturate((abs(_unknownUnnormalizedDir0.y) - 0.2) * 3.3333));
                float noneNegativePackedVdU1 = max(packedVdU1, 0);
                // r1.zw = r0.ww + float2(-0.3, -0.5);
                // r1.z = r0.w - 0.3;
                float noneNegativeVdU1 = noneNegativePackedVdU1 - 0.5;
                // r1.z = saturate((r0.w - 0.3) * 1.4286);
                r3.w = smoothstep(saturate((noneNegativePackedVdU1 - 0.3) * 1.4286));
                // r2.w = 3 - 2 * r1.z;
                // r1.z = r1.z * r1.z;
                // r3.w = r1.z * r2.w;
                float3 unknownMixedColor = unknownColor * lerp(1, r0.z, r3.w) + mixedColor7_8_9_10;
                
                r0.w = log(min(noneNegativePackedVdU1, 1));
                r0.z = abs(vdl) * _cb0_17.w;
                r1.z = r0.w * r0.z;
                r3.xyz = exp(float3(0.1, 0.1, 0.5) * r0.z * r0.w);
                r3.xy = min(r3.xy, 1);
                // float4 r4;
                float3 noiseRColorBase = saturate(vdl * r3.z) * _cb0_18.w * _cb0_16.xyz;
                r3.xyz = (min(1, exp(r1.z)) + r3.x * 0.12 + r3.y * 0.03) * _cb0_18.w * _cb0_18.xyz;
                r0.z = smoothstep(saturate(noneNegativeVdU1 * 2));
                o.v5_SkyColor.xyz = r3.xyz * r0.z + unknownMixedColor;


                float packedVdU2 = vdu2 * 0.5 + 0.5;

                r0.z = smoothstep(max((pow(saturate(vdu2), 5) - 0.5) * 2, 0)) * _cb0_21.x;
                float3 noiseRColor = _cb0_20.xyz * (1 - 2 * abs(_cb0_21.y - 0.5)) * r0.z * clamp(_cb0_20.w, 0, 0.8) + noiseRColorBase;

                o.v6_cb0_16Color.xyz = noiseRColor * smoothstep(saturate(2.5 * (0.7 - _cb0_27.z)));
                r0.xy = saturate(linearstep(float2(packedVdU2, packedVdU1), _cb0_17.z, 1));
                float curve20 = pow(smoothstep(r0.x) * _cb0_20.w * 0.1, 2);
                float curve18 = pow(smoothstep(r0.y) * _cb0_16.w * 0.125, 2);
                o.v7_noiseGColor.xyz = r0.z * (curve18 * _cb0_18.xyz + curve20 * _cb0_20.xyz);
                r0.x = pow(r1.y, 3);
                o.v8_unknownColor.xyz = lerp(_BrightColor0.xyz, _BrightColor1.xyz, r0.x);
                o.v9_unknownColor.xyz = lerp(_DarkColor0.xyz, _DarkColor1.xyz, r0.x);

                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return float4(i.temp.xy, 0, 1); 
                // half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // return float4(i.uv.xy * _GridNum.xy * 0.125, 0, 1);
                float4 r0;
                r0.x = i.v3.w  + 0.1;
                r0.x = saturate(r0.x * 5);

                r0.x = smoothstep(r0.x);
                // r0.y = -2 * r0.x + 3;
                // r0.x = r0.x * r0.x;
                // r0.x = r0.x * r0.y;

                r0.yz = min(i.v4.yz + i.v4.ww, 1);
                // r0.yz = i.v4.yz + i.v4.w;
                // r0.yz = min(r0.yz, 1);
                r0.w = max(i.v4.w - i.v4.y, 0);
                r0.yz = 1 / (r0.yz - r0.w);
                // r0.yz = r0.yz - r0.w;
                // r0.yz = 1/r0.yz;
                
                float4 r1;
                r1.xyz = SAMPLE_TEXTURE2D(_Tex0, sampler_Tex1, i.uv.zw);
                float2 dissolveUV = (r1.xy - 0.5) * r1.z * _DissolveStr;
                float2 uv = dissolveUV + i.uv.xy;
                r1.xyzw = SAMPLE_TEXTURE2D(_Tex1, sampler_Tex0, uv);
                // return float4(r1.xyz, 1);
                
                
                float4 cloud = r1.xyzw;
                float light = cloud.x;
                float edge = cloud.y;
                float thickness = cloud.z;
                float mask = cloud.w;
                r0.w = max(i.v4.w - i.v4.y, 0);
                r0.yz = 1 / (min(i.v4.yz + i.v4.w, 1) - r0.w);
                r0.w = thickness - r0.w;
                r0.yz = saturate(r0.yz * r0.w);

                float4 r2;
                // r0.y = smoothstep(r0.y);
                r2.xy = -2 * r0.yz + 3;
                r0.yz = r0.yz * r0.yz;
                r0.y = r0.y * r2.x;
                float cloudG_Str =  ((1 - r2.y * r0.z) * 4 - edge) * i.v4.w + edge;


                float alpha_output = smoothstep(saturate((i.v3.w + 0.1) * 5))   /** r0.y*/ * mask;
                // return float4(alpha_output.xxx, 1);
                clip(alpha_output - 0.01);
                float3 color = cloudG_Str * i.v7_noiseGColor.xyz +  lerp(i.v8_unknownColor.xyz , i.v9_unknownColor.xyz, light);

                float3 added_color = i.v8_unknownColor.xyz * _cb0_27.z;

                float unknown_str = i.v4.x + 1;
                color = (color + added_color * 0.4 + i.v6_cb0_16Color.xyz * light) * unknown_str - i.v5_SkyColor.xyz;

                float light_str = smoothstep(saturate((_cb0_27.z - 0.4) * 3.3333));
                float balance = min(smoothstep(saturate(i.v3.w * 10)), 1);
                light_str = lerp(1, light_str, balance);
                float3 color_output = color * light_str  + i.v5_SkyColor.xyz;
                return float4(color_output, alpha_output);
            }
            ENDHLSL
        }
    }
}
