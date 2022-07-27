#ifndef MF_MATH_UTILITY_INCLUDED
#define MF_MATH_UTILITY_INCLUDED

float3 Curve(float3 color, float k)
{
    return exp(log(max(color, int3(0, 0, 0))) * k);
}

float3 CelColorMix(float3 color1, float3 color2)
{
    return max(color1, color2) * min(color1, color2);
}

float3 CelColorGradient(float3 color1, float3 color2, float per)
{
    return lerp(color1, color2, per) + CelColorMix(color1, color2) * saturate( 1-abs(per * 2 - 1));
}

float3 ColorCurveMapping(float3 color, float k)
{
    return exp(log(max(color, int3(0, 0, 0))) * k);
}

float linearstep(float data, float min, float max)
{
    return (data - min) / (max - min);
}

float2 linearstep(float2 data, float min, float max)
{
    return (data.xy - min.xx) / (max.xx - min.xx);
}

float3 linearstep(float3 data, float min, float max)
{
    return (data.xyz - min.xxx) / (max.xxx - min.xxx);
}

float4 linearstep(float4 data, float min, float max)
{
    return (data.xyzw - min.xxxx) / (max.xxxx - min.xxxx);
}

float ScreenSpaceDither(float2 screenPos, float transparency)
{
    float4x4 thresholdMatrix =
   {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    float2 index = fmod(screenPos.xy, 4);
    clip(transparency - thresholdMatrix[index.x][index.y]);
}
#endif