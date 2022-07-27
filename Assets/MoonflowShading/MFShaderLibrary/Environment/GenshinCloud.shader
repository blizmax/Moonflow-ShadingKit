Shader"Test/GenshinCloud"
{
    Properties
    {
        _GradientTex("Gradient", 2D) = "gray"{}
        _NoiseTex ("Noise", 2D) = "white" {}
        _MaskTex ("Mask", 2D) = "white"{}
        
        _CameraPlanarPos("(传入)相机坐标（去除y）",Vector) = (0,0,-46.00281,0)
        _SkyTopLightDir("(传入)天光（默认垂直向下）",Vector) = (0,1,0,0)
        _MainSkyLight("(传入)主光 方向", Vector) = (-0.67019, 0.50162, 0.54701, 0)
        _cloudEdgeLight("(传入)云边缘光 光源 方向", Vector) = (0.46066, -0.71634, 0.52406, 0)
        [Space(10)]
        _SkyColorGroup1Back("背景色 第1组 远离光源",Color) = (0.02719, 0.05757, 0.18782, 0)
        _SkyColorGroup1Front("背景色 第1组 临近光源",Color) = (0.01329, 0.04425, 0.18125, 0)
        _SkyColorGroup0Back("背景色 第0组 远离光源",Color) = (0.0687, 0.24619, 0.45641, 0)
        _SkyColorGroup0Front("背景色 第0组 接近光源",Color) = (0.04328, 0.29054, 0.6398, 0.50569)
        _SkyColorNoiseSamplePos("背景色混合随机采样点", Range(0,1)) = 0.40979
        _SunSkyColor("天光色", Color) = (0.34851, 0.74134, 1, 1)
        _SunSkyIntensity("天光色强度", Float) = 1.24741
        _SunSkyNoiseSamplePos("天光色强度叠加随机采样点", Range(0,1)) = 0.49728
        _cloudLightenColor("云亮部颜色",Color) = (1, 0.99262, 0.86738, 9.92669)
//        _cb0_17("17",Vector) = (0, 0, 1, 999.37653)
        _CloudSunLightenAttenuation("云边缘阳光透射衰减速度(值越大衰减越快)", Float) = 999.37653
        _cloudEdgeMinStr("边缘最低亮度", Range(0,1)) = 1
        _MainSkyLightColor("主光 颜色",Color) = (0.70543, 0.76732, 0.76504, 0)
        _cloudLightenStr("云亮暗叠色 强度", Range(0,1)) = 0.50917
        _cloudEdgeLightColor("云边缘光 光源 颜色",Color) = (0.15648, 0.18993, 0.26669, 0.03339)
//        _cb0_21("21",Vector) = (0.00213, 0.627, 24.44967, 0)
        _CloudEdgeLighten("云层边缘透光强度", Float) = 0.00213
        _CloudDarkLighten("云层暗部透光强度(0.5最强，双向递减)", Float) = 0.627
        _BrightColor0("云层亮部混合0",Color) = (1, 0.89974, 0.7816, 0)
        _BrightColor1("云层亮部混合1",Color) = (1, 0.89974, 0.7816, 0)
        _DarkColor0("云层暗部混合0",Color) = (0, 0.27366, 0.45641, 0)
        _DarkColor1("云层暗部混合1",Color) = (0, 0.40506, 1, 0)
//        _cb0_27("27",Vector) = (0, 0, 0.11, 1)
        _CloudClip("云层消減", Float) = 1
        _EdgeSkyMix("天空混合", Range(0,1)) = 0.11
        _CloudIntensity("云层亮度", Float) = 1
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
                float4 color : COLOR;//粒子系统CustomData覆盖，x是bool，y转译为序号决定生成云的形状，zw恒为0.09804
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 v1_scaledCenterScreenPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 viewDir : TEXCOORD2;
                float4 v4 : TEXCOORD3;
                float3 v5_SkyColor : TEXCOORD4;
                float3 v6_cloudLightenColor : TEXCOORD5;
                float3 v7_cloudEdgeColor : TEXCOORD6;
                float3 v8_brightColor : TEXCOORD7;
                float3 v8_darkColor : TEXCOORD8;
                float4 temp: TEXCOORD9;
            };

            Texture2D _NoiseTex;
            SamplerState sampler_NoiseTex;
            Texture2D _MaskTex;
            SamplerState sampler_MaskTex;
            
            Texture2D _GradientTex;
            SamplerState sampler_GradientTex;

            float4 _CameraPlanarPos;
            float4 _SkyTopLightDir;
            float4 _SkyColorGroup1Back;
            float4 _SkyColorGroup1Front;
            float4 _SkyColorGroup0Back;
            float4 _SkyColorGroup0Front;
            float _SkyColorNoiseSamplePos;
            float3 _SunSkyColor;
            float _SunSkyIntensity;
            float _SunSkyNoiseSamplePos;
            float3 _MainSkyLight;
            
            float4 _cloudLightenColor;
            // float4 _cb0_17;
            float _CloudSunLightenAttenuation;
            float _cloudEdgeMinStr;
            float4 _MainSkyLightColor;
            float _cloudLightenStr;
            float3 _cloudEdgeLight;
            float4 _cloudEdgeLightColor;
            // float4 _cb0_21;
            float _CloudEdgeLighten;
            float _CloudDarkLighten;
            float4 _BrightColor0;
            float4 _BrightColor1;
            float4 _DarkColor0;
            float4 _DarkColor1;
            // float4 _cb0_27;
            float _CloudClip;
            float _CloudIntensity;
            float4 _GridNum;
            float _DissolveStr;
            float _DissolveScale;
            float _DissolveSpeed;
            float _EdgeSkyMix;

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

                //v1
                float4 r2 = 0;
                float3 worldDir = posWS - /*_WorldSpaceCameraPos*/_CameraPlanarPos.xyz;
                float4 halfPosCS = o.vertex * 0.5;
                o.v1_scaledCenterScreenPos = float4(halfPosCS.x + halfPosCS.z, halfPosCS.y * _ProjectionParams.x + halfPosCS.z, 0, o.vertex.z);

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

                //========== viewDir: viewDir + 未知alpha系数 =========
                float3 viewDir = normalize(worldDir);
                float vds = dot(_SkyTopLightDir.xyz, viewDir);
                float clampedVdS = clamp(vds, -1, 1);
                /*y=arcsin(x*1.6)拟合*/
                float temp1 = ((-0.0187 * abs(clampedVdS) + 0.0743) * abs(clampedVdS) - 0.2121) * abs(clampedVdS) + PI * 0.5;
                float temp2 = sqrt(1 - abs(clampedVdS));//接近垂直时为1，接近平行为0
                float lightSide = clampedVdS > 0;
                //vds<0部分符合y=arcsin(x)/1.6 x取[-1,0]的段， vds>0部分符合y=arcsin(x)/1.6 - 0.2*PI x取[0,1]的段
                r0.w = (temp1 * temp2 - lightSide - PI * 0.5) * PI * 0.2;
                o.viewDir = float4(viewDir, r0.w);

                
                //========== v4 ? ============
                r1.z = tl46.y / max(tl46.x, 0) * _CloudClip;
                r1.y = 1 - smoothstep(saturate(linearstep(r1.z, tl46.w, 1)));
                r1.z = smoothstep(saturate(1 / tl46.z * r1.z));

                o.v4.w = -r1.z * r1.y + 1;
                float vdSkyMainL = dot(viewDir, _MainSkyLight.xyz);
                float vdel1 = dot(viewDir, _cloudEdgeLight.xyz);
                float lambertVdSkyLight = vdSkyMainL * 0.5 + 0.5;
                o.v4.x = lambertVdSkyLight * _CloudIntensity;
                o.v4.yz = v.color.zw;

                //=========== v5 ? ============
                
                float skyMainLightMix= max(lerp(vdSkyMainL, 1, _SkyColorGroup0Front.w), 0);
                r1.y = max(lerp(vdSkyMainL, 1, _DarkColor1.w), 0);
                float editedSkyLightStr = pow(skyMainLightMix, 3);
                float3 skyGroup0 = lerp(_SkyColorGroup0Back.xyz, _SkyColorGroup0Front.xyz, editedSkyLightStr);
                float3 skyGroup1 = lerp(_SkyColorGroup1Back.xyz, _SkyColorGroup1Front.xyz, editedSkyLightStr);

                
                float projectedCurve0 = abs(r0.w)/max(_SkyColorNoiseSamplePos, 0.0001);
                float GradientSample0 = LOAD_TEXTURE2D_X(_GradientTex, float2(projectedCurve0, 0.5)).x;
                float3 MixSkyColor = lerp(skyGroup0, skyGroup1, GradientSample0);

                float projectedCurve1 = abs(r0.w)/max(_SunSkyNoiseSamplePos, 0.0001);
                float SkyLightInfluenceGradient = LOAD_TEXTURE2D_X(_GradientTex, float2(projectedCurve1, 0.5)).y;
                float3 skyLightInfluenceColor = _SunSkyColor.xyz * _SunSkyIntensity * SkyLightInfluenceGradient;

                //主天光朝向垂直方向分量remap，强度在y值于0.2-0.5之间重映射到0-1，小于0.2强度恒为0，大于0.5强度恒为1
                float remappedSkyLightY = smoothstep(saturate((abs(_MainSkyLight.y) - 0.2) * 3.3333));
                //remap的vdl, -0.4 smooth到 1, vds=0时值为0.2
                float remappedVdSkyLight = smoothstep(saturate((max(lambertVdSkyLight, 0) - 0.3) * 1.4286));
                //参数vdl与太阳y方向分量
                float skyLightInfluence = lerp(1, remappedSkyLightY, remappedVdSkyLight);
                float3 skyHorizonMix = skyLightInfluenceColor * skyLightInfluence + MixSkyColor;
                

                //包括天光附近和天光侧地平线附近的提亮
                float3 CloudSunLightenRange = min(exp(log(saturate(lambertVdSkyLight)) * abs(vds) * _CloudSunLightenAttenuation * float3(0.1, 0.1, 0.5)), 1);
                float3 cloudLightenColorInside = saturate(vds * CloudSunLightenRange.z) * _cloudLightenStr * _cloudLightenColor.xyz;
                float3 skyLightInfluencedColor = (min(1, exp(r1.z)) + CloudSunLightenRange.x * 0.12 + CloudSunLightenRange.y * 0.03) * _cloudLightenStr * _MainSkyLightColor.xyz;
                o.v5_SkyColor.xyz = skyLightInfluencedColor * smoothstep(saturate(vdSkyMainL)) + skyHorizonMix;
                
                //========= v6 ============
                float lambertVdEL1 = vdel1 * 0.5 + 0.5;
                r0.z = smoothstep(max((pow(saturate(vdel1), 5) - 0.5) * 2, 0)) * _CloudEdgeLighten;
                float3 lightenCloud = _cloudEdgeLightColor.xyz * (1 - 2 * abs(_CloudDarkLighten- 0.5)) * r0.z * clamp(_cloudEdgeLightColor.w, 0, 0.8) + cloudLightenColorInside;
                o.temp.xyz = lightenCloud;
                o.v6_cloudLightenColor.xyz = lightenCloud * smoothstep(saturate(2.5 * (0.7 - _EdgeSkyMix)));

                //======== v7-v9 ============
                float2 remapVdEL = saturate(linearstep(float2(lambertVdEL1, lambertVdSkyLight), _cloudEdgeMinStr, 1));
                float curve20 = pow(smoothstep(remapVdEL.x) * _cloudEdgeLightColor.w * 0.1, 2);
                float skyLightIntensityCurve = pow(smoothstep(remapVdEL.y) * _cloudLightenColor.w * 0.125, 2);
                // o.v7_cloudEdgeColor.xyz = _cloudEdgeLightColor.www;
                o.v7_cloudEdgeColor.xyz = r0.z * (skyLightIntensityCurve * _MainSkyLightColor.xyz + curve20 * _cloudEdgeLightColor.xyz);
// o.temp.xyz = o.v7_cloudEdgeColor.xyz;

                r0.x = pow(r1.y, 3);
                o.v8_brightColor.xyz = lerp(_BrightColor0.xyz, _BrightColor1.xyz, r0.x);
                o.v8_darkColor.xyz = lerp(_DarkColor0.xyz, _DarkColor1.xyz, r0.x);

                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {

                float4 r0;
                
                float4 r1;
                r1.xyz = SAMPLE_TEXTURE2D(_NoiseTex, sampler_MaskTex, i.uv.zw);
                float2 dissolveUV = (r1.xy - 0.5) * r1.z * _DissolveStr;
                float2 uv = dissolveUV + i.uv.xy;
                r1.xyzw = SAMPLE_TEXTURE2D(_MaskTex, sampler_NoiseTex, uv);
                // return float4(r1.xyz, 1);
                
                
                float4 cloud = r1.xyzw;
                float light = cloud.x;
                float edge = cloud.y;
                float thickness = cloud.z;
                float mask = cloud.w;
                r0.w = max(i.v4.w - i.v4.y, 0);
                r0.yz = 1 / (min(i.v4.yz + i.v4.w, 1) - r0.w);
                r0.yz = saturate(r0.yz * (thickness - r0.w));

                float cloudEdgeStr =  ((1 - smoothstep(r0.z)) * 4 - edge) * i.v4.w + edge;


                float alpha_output = smoothstep(saturate((abs(i.viewDir.w) + 0.1) * 5)) * smoothstep(r0.y) * mask;
                clip(alpha_output - 0.01);
                float3 color = cloudEdgeStr * i.v7_cloudEdgeColor.xyz + lerp(i.v8_brightColor.xyz , i.v8_darkColor.xyz, light);

                float3 added_color = i.v8_brightColor.xyz * _EdgeSkyMix;

                float cloudAddIntensity = i.v4.x + 1;
                color = (color + added_color * 0.4 + i.v6_cloudLightenColor.xyz * light) * cloudAddIntensity - i.v5_SkyColor.xyz;
                float light_str = smoothstep(saturate((_EdgeSkyMix - 0.4) * 3.3333));
                float balance = min(smoothstep(saturate(i.viewDir.w * 10)), 1);
                light_str = lerp(1, light_str, balance);
                float3 color_output = color * light_str  + i.v5_SkyColor.xyz;
                return float4(color_output, alpha_output);
            }
            ENDHLSL
        }
    }
}
