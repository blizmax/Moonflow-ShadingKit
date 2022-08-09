#ifndef MF_HASH_INCLUDED
#define MF_HASH_INCLUDED

float4 hash4( float2 p )
{
   return frac(sin(float4( 1.0+dot(p,float2(37.0,17.0)), 
         2.0+dot(p,float2(11.0,47.0)),
         3.0+dot(p,float2(41.0,29.0)),
         4.0+dot(p,float2(23.0,31.0))))*103.0);
}

float2 hash2D (float2 s)
{
    return frac(sin(fmod(float2(dot(s, float2(127.1,311.7)), dot(s, float2(269.5,183.3))), 3.14159))*43758.5453);
}

//https://drive.google.com/file/d/1QecekuuyWgw68HU9tg6ENfrCTCVIjm6l/view
//https://github.com/UnityLabs/procedural-stochastic-texturing/blob/master/Editor/ProceduralTexture2D/SampleProceduralTexture2DNode.cs
//0->uv 1
float2 TDEHHash2D(float2 p)
{
    return frac(sin(mul(p, float2x2(127.1, 311.7, 269.5, 183.3))) * 43758.5453);
}
#endif