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
        _cb0_12("12",Vector) = (0.40979, 0.34851, 0.74134, 1)
        _cb0_13("13",Vector) = (1.24741, 0, 0, 0)
        _cb0_15("15",Vector) = (0.49728, -0.67019, 0.50162, 0.54701)
        _cb0_16("16",Vector) = (1, 0.99262, 0.86738, 9.92669)
        _cb0_17("17",Vector) = (0, 0, 1, 999.37653)
        _cb0_18("18",Color) = (0.70543, 0.76732, 0.76504, 0.50917)
        _cb0_19("19",Vector) = (0.46066, -0.71634, 0.52406, 0)
        _cb0_20("20",Color) = (0.15648, 0.18993, 0.26669, 0.03339)
        _cb0_21("21",Vector) = (0.00213, 0.627, 24.44967, 0)
        _cb0_23("23",Color) = (1, 0.89974, 0.7816, 0)
        _cb0_24("24",Color) = (1, 0.89974, 0.7816, 0)
        _cb0_25("25",Color) = (0, 0.27366, 0.45641, 0)
        _cb0_26("26",Color) = (0, 0.40506, 1, 0)
        _cb0_27("27",Vector) = (0, 0, 0.11, 1)
        _cb0_28("28",Vector) = (0,0,0,1)
        _cb_zwTilling("35", Vector) = (0,0,2,4)
        _cb0_36("36",Vector) = (3, 0.015, 6, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float3 v5_baseColor : TEXCOORD4;
                float3 v6_noiseRColor : TEXCOORD5;
                float3 v7_noiseGColor : TEXCOORD6;
                float3 v8_unknownColor : TEXCOORD7;
                float3 v9_unknownColor : TEXCOORD8;
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
            float4 _cb0_12;
            float4 _cb0_13;
            float4 _cb0_15;
            float4 _cb0_16;
            float4 _cb0_17;
            float4 _cb0_18;
            float4 _cb0_19;
            float4 _cb0_20;
            float4 _cb0_21;
            float4 _cb0_23;
            float4 _cb0_24;
            float4 _cb0_25;
            float4 _cb0_26;
            float4 _cb0_27;
            float4 _cb0_28;
            float4 _cb0_36;
            float4 _cb_zwTilling;

            float smoothstep(float input)
            {
                return (3 - input * 2) * input * input;
            }
            float linearstep(float x, float min, float max)
            {
                return (x - min) / (max - min);
            }

            v2f vert (appdata v)
            {
                float4 tl46 = v.tl46;
                tl46 = float4(233.20918, 26.16353, 0.4, 0.6);
                v2f o;
                float4 r0;
                float4 r1;
                o.vertex = TransformObjectToHClip(v.vertex);
                float3 posWS = TransformObjectToWorld(v.vertex);
                r1.xyz = o.vertex;
                
                float4 r2 = 0;
                float3 worldDir = posWS - _CameraPlanarPos.xyz;
                float4 halfPosCS = o.vertex * 0.5;
                o.v1_mayCenterScreenPos = float4(halfPosCS.x + halfPosCS.z, halfPosCS.y * _ProjectionParams.x + halfPosCS.z, 0, o.vertex.z);

                //========== 云的序号 =============
                r0.w = round((_cb_zwTilling.z * _cb_zwTilling.w - 1) * v.color.y + 0.5);
                r1.x = r0.w * _cb_zwTilling.z;
                r1.x = (r1.x > 0 ? 1 : -1) * _cb_zwTilling.z;
                r1.y = 1 / r1.x * r0.w;
                r2.y = round(r0.w / _cb_zwTilling.z);
                r2.x = frac(r1.y) * r1.x;
                //r2.xy决定是贴图上的哪朵云
                float2 SingleCloudUV = r2.xy + v.uv.xy;
                o.uv.xy = SingleCloudUV / _cb_zwTilling.zw;
                float2 uvOffset = float2(1.2, _cb0_36.z) * float2(_cb0_36.z, 0.8) * _cb0_21.z;
                o.uv.zw = v.uv.xy * _cb0_36.x + uvOffset;

                float3 viewDir = normalize(worldDir);
                float vdl = dot(_CloudLightDir.xyz, viewDir);
                float clampedVdL = clamp(vdl, -1, 1);
                float unknown_Radian = ((-0.0187 * abs(clampedVdL) + 0.0743) * abs(clampedVdL) - 0.2121) * abs(clampedVdL) + PI * 0.5;
                float sqrtVertical = sqrt(1 - abs(clampedVdL));//接近垂直时为1，接近平行为0
                float lightSide = clampedVdL > 0;
                r0.w = (unknown_Radian * sqrtVertical - lightSide - PI * 0.5) * PI * 0.2;
                o.v3 = float4(viewDir, r0.w);
                
                r1.z = tl46.y / max(tl46.x, 0) * _cb0_27.w;
                r1.y = 1 - smoothstep(saturate(linearstep(r1.z, tl46.w, 1)));
                r1.z = smoothstep(saturate(1 / tl46.z * r1.z));
                r1.w = 1 / tl46.z;

                o.v4.w = -r1.z * r1.y + 1;
                float vdu1 = dot(viewDir, _cb0_15.yzw);
                r0.x = dot(viewDir, _cb0_19.xyz);
                r0.y = vdu1 * 0.5 + 0.5;
                o.v4.x = r0.y * _cb0_28.w;
                o.v4.yz = v.color.zw;

                r0.z = max(lerp(vdu1, 1, _cb0_26.w), 0);
                r1.y = max(lerp(vdu1, 1, _cb0_26.w), 0);
                r0.z = pow(r0.z, 3);
                r2.xyz = lerp(_cb0_9.xyz, _cb0_10.xyz, r0.z);
                float4 r3;
                r3.xyz = lerp(_cb0_7.xyz, _cb0_8.xyz, r0.z);
                
                r0.z = LOAD_TEXTURE2D_X(_Tex0, float2(abs(r0.w)/max(_cb0_12.x, 0.0001), 0.5)).x;
                r2.xyz = lerp(r2.xyz, r3.xyz, r0.z);
                r0.z = LOAD_TEXTURE2D_X(_Tex0, float2(abs(r0.w)/max(_cb0_15.x, 0.0001), 0.5)).x;
                r3.xyz = _cb0_12.yzw * _cb0_13.x;
                r3.xyz = r3.xyz * r0.z;

                r0.z = abs(_cb0_15.z) - 0.2;
                r0.z = saturate(r0.z * 3.3333);
                r0.z = smoothstep(r0.z);

                r0.w = max(r0.y, 0);
                r1.zw = r0.ww + float2(-0.3, -0.5);
                r1.z = saturate(r1.z * 1.4286);
                r3.w = smoothstep(r1.z);
                r2.xyz = r3.xyz * (r0.z * (1 - r2.w * r1.z) + r3.w) + r2.xyz;
                r0.w = log(min(r0.w, 1));
                r0.z = abs(vdl) * _cb0_17.w;
                r1.z = r0.w * r0.z;
                r3.xyz = exp(float3(0.1, 0.1, 0.5) * r0.z * r0.w);
                r3.xy = min(r3.xy, 1);
                float4 r4;
                r4.xyz = saturate(vdl * r3.z) * _cb0_18.w * _cb0_16.xyz;
                r3.xyz = (min(1, exp(r1.z)) + r3.x * 0.12 + r3.y * 0.03) * _cb0_18.w * _cb0_18.xyz;
                r0.z = smoothstep(saturate(r1.w * 2));
                o.v5_baseColor.xyz = r3.xyz * r0.z + r2.xyz;

                r0.z = saturate(r0.x);
                r0.x = r0.x * 0.5 + 0.5;
                r0.xy = r0.xy - _cb0_17.z;

                r0.z = smoothstep(max((pow(r0.z, 5) - 0.5) * 2, 0)) * _cb0_21.x;
                r1.xzw = _cb0_20.xyz * (1 - 2 * abs(_cb0_21.y - 0.5)) * r0.z * clamp(_cb0_20.w, 0, 0.8) + r4.xyz;

                o.v6_noiseRColor.xyz = r1.xzw * smoothstep(saturate(2.5 * (0.7 - _cb0_27.z)));
                r0.xy = saturate(r0.xy / (1 - _cb0_17.z));
                r0.x = pow(smoothstep(r0.x) * _cb0_20.w * 0.1, 2);
                r1.xzw = r0.x * _cb0_20.xyz;

                r0.x = pow(smoothstep(r0.y) * _cb0_16.w * 0.125, 2);
                o.v7_noiseGColor.xyz = r0.z * (r0.x * _cb0_18.xyz + r1.xzw);
                r0.x = pow(r1.y, 3);
                o.v8_unknownColor.xyz = lerp(_cb0_23.xyz, _cb0_24.xyz, r0.x);
                o.v9_unknownColor.xyz = lerp(_cb0_25.xyz, _cb0_26.xyz, r0.x);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return float4(i.uv.xy * _cb_zwTilling.zw * 0.125, 0, 1);
                float4 r0;
                r0.x = i.v3.w  + 0.1;
                r0.x = saturate(r0.x * 5);

                r0.x = smoothstep(r0.x);
                // r0.y = -2 * r0.x + 3;
                // r0.x = r0.x * r0.x;
                // r0.x = r0.x * r0.y;

                r0.yz = i.v4.yz + i.v4.w;
                r0.yz = min(r0.yz, 1);
                r0.w = max(i.v4.w - i.v4.y, 0);
                r0.yz = r0.yz - r0.w;
                r0.yz = 1/r0.yz;
                
                float4 r1;
                r1.xyz = SAMPLE_TEXTURE2D(_Tex1, sampler_Tex1, i.uv.zw);
                float lighting = r1.x;
                float edgemask = r1.y;
                float2 le = float2(lighting, edgemask);
                float thickness = r1.z;
                le = (le - 0.5) * thickness * _cb0_36.y + i.uv.xy;
                r1.xyzw = SAMPLE_TEXTURE2D(_Tex0, sampler_Tex0, le);
                return float4(r1.xyz, 1);
                
                float4 curl = r1.xyzw;
                
                r0.w = max(i.v4.w - i.v4.y, 0);
                r0.yz = 1 / (min(i.v4.yz + i.v4.w, 1) - r0.w);
                r0.w = curl.z - r0.w;
                r0.yz = saturate(r0.yz * r0.w);

                float4 r2;
                // r0.y = smoothstep(r0.y);
                r2.xy = -2 * r0.yz + 3;
                r0.yz = r0.yz * r0.yz;
                r0.y = r0.y * r2.x;
                float curlG_Str =  ((1 - r2.y * r0.z) * 4 - curl.y) * i.v4.w + curl.y;

                float clip_alpha = r0.y * curl.w * r0.x - 0.01;
                float alpha_output = smoothstep(saturate((i.v3.w + 0.1) * 5)) * r0.y;

                // clip(clip_alpha);
                float3 color = curlG_Str * i.v7_noiseGColor.xyz +  lerp(i.v8_unknownColor.xyz , i.v9_unknownColor.xyz, curl.x);

                float3 added_color = i.v8_unknownColor.xyz * _cb0_27.z;

                float unknown_str = i.v4.x + 1;
                color = (color + added_color * 0.4 + i.v6_noiseRColor.xyz * curl.x) * unknown_str - i.v5_baseColor.xyz;

                float light_str = smoothstep(saturate((_cb0_27.z - 0.4) * 3.3333));
                float balance = min(smoothstep(saturate(i.v3.w * 10)), 1);
                light_str = lerp(1, light_str, balance);
                float3 color_output = color * light_str  + i.v5_baseColor.xyz;
                // return 1;
                return float4(color_output, alpha_output);
            }
            ENDHLSL
        }
    }
}
