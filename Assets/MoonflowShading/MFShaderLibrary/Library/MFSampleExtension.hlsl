#ifndef MF_UTILITY_INCLUDED
#define MF_UTILITY_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#define StochasticTex(tex, texSampler, uvData) InigoRepetition1(tex, texSampler, uvData)

half4 hash4( half2 p )
{
    return frac(sin(half4( 1.0+dot(p,half2(37.0,17.0)), 
          2.0+dot(p,half2(11.0,47.0)),
          3.0+dot(p,half2(41.0,29.0)),
          4.0+dot(p,half2(23.0,31.0))))*103.0);
}

//4 times
//https://iquilezles.org/articles/texturerepetition/
float4 InigoRepetition1(TEXTURE2D_PARAM(tex, texSampler), float2 uv)
{
    float2 iuv = floor(uv);
    float2 fuv = frac(uv);

    float4 ofa = hash4(iuv + half2(0,0));
    float4 ofb = hash4(iuv + half2(1,0));
    float4 ofc = hash4(iuv + half2(0,1));
    float4 ofd = hash4(iuv + half2(1,1));

    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    ofa.zw = sign( ofa.zw-0.5 );
    ofb.zw = sign( ofb.zw-0.5 );
    ofc.zw = sign( ofc.zw-0.5 );
    ofd.zw = sign( ofd.zw-0.5 );

    float2 uva = uv*ofa.zw + ofa.xy, ddxa = dx*ofa.zw, ddya = dy*ofa.zw;
    float2 uvb = uv*ofb.zw + ofb.xy, ddxb = dx*ofb.zw, ddyb = dy*ofb.zw;
    float2 uvc = uv*ofc.zw + ofc.xy, ddxc = dx*ofc.zw, ddyc = dy*ofc.zw;
    float2 uvd = uv*ofd.zw + ofd.xy, ddxd = dx*ofd.zw, ddyd = dy*ofd.zw;

    float2 b = smoothstep( 0.25,0.75, fuv );
    
    return lerp( lerp( SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uva, ddxa, ddya ), 
                     SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uvb, ddxb, ddyb ), b.x ), 
                lerp( SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uvc, ddxc, ddyc ),
                     SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uvd, ddxd, ddyd ), b.x), b.y );
}

//9 times
//https://iquilezles.org/articles/texturerepetition/
float4 InigoRepetition2(TEXTURE2D_PARAM(tex, texSampler), float2 uv)
{
    float2 p = floor(uv);
    float2 f = frac(uv);

    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    float4 va = 0;
    float wt = 0;
    UNITY_UNROLL
    for(int j = -1; j <= 1; j++)
    {
        for(int i = -1; i <= 1; i++)
        {
            float2 g = float2(i, j);
            float4 o = hash4(p + g);
            float2 r = g - f + o.xy;
            float d = dot(r, r);
            float w = exp(-5.0 * d);
            float4 c = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv + o.zw, dx, dy);
            va += w * c;
            wt += w;
        }
    }
    return va/wt;
}

//3 times
//https://iquilezles.org/articles/texturerepetition/
float4 InigoRepetition3O(TEXTURE2D_PARAM(tex, texSampler), float2 uv, TEXTURE2D_PARAM(noise, noiseSampler))
{
    float k = SAMPLE_TEXTURE2D(noise, noiseSampler, uv * 0.005).x;
    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    float index = k * 8.0;
    float f = frac(index);
    
    float i  = floor(index);

    float2 offa = sin(float2(3, 7) * hash4(i));
    float2 offb = sin(float2(3, 7) * hash4(i + 1));

    float4 cola = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv + offa, dx, dy);
    float4 colb = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv + offb, dx, dy);

    float4 sub = cola - colb;
    return lerp(cola, colb, Smootherstep(0.2, 0.8, f - 0.1 * (sub.r + sub.g + sub.b)));
}

float2 hash2D2D (float2 s)
{
    return frac(sin(fmod(float2(dot(s, float2(127.1,311.7)), dot(s, float2(269.5,183.3))), 3.14159))*43758.5453);
}
//3 times
//https://pastebin.com/Av1ZPQmC
float4 PastebinRepetition(TEXTURE2D_PARAM(tex, texSampler), float2 uv)
{
    //triangle vertices and blend weights
    //BW_vx[0...2].xyz = triangle verts
    //BW_vx[3].xy = blend weights (z is unused)
    float4x3 BW_vx;
 
    //uv transformed into triangular grid space with uv scaled by approximation of 2*sqrt(3)
    float2 skewuv = mul(float2x2 (1.0 , 0.0 , -0.57735027 , 1.15470054), uv * 3.464);
 
    //vertex IDs and barycentric coords
    float2 vxID = float2 (floor(skewuv));
    float3 barry = float3 (frac(skewuv), 0);
    barry.z = 1.0-barry.x-barry.y;
 
    BW_vx = ((barry.z>0) ? 
        float4x3(float3(vxID, 0), float3(vxID + float2(0, 1), 0), float3(vxID + float2(1, 0), 0), barry.zyx) :
        float4x3(float3(vxID + float2 (1, 1), 0), float3(vxID + float2 (1, 0), 0), float3(vxID + float2 (0, 1), 0), float3(-barry.z, 1.0-barry.y, 1.0-barry.x)));
 
    //calculate derivatives to avoid triangular grid artifacts
    float2 dx = ddx(uv);
    float2 dy = ddy(uv);
 
    //blend samples with calculated weights
    return mul(SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv + hash2D2D(BW_vx[0].xy), dx, dy), BW_vx[3].x) + 
            mul(SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv + hash2D2D(BW_vx[1].xy), dx, dy), BW_vx[3].y) + 
            mul(SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv + hash2D2D(BW_vx[2].xy), dx, dy), BW_vx[3].z);
}

//https://drive.google.com/file/d/1QecekuuyWgw68HU9tg6ENfrCTCVIjm6l/view
//https://github.com/UnityLabs/procedural-stochastic-texturing/blob/master/Editor/ProceduralTexture2D/SampleProceduralTexture2DNode.cs
//0->uv 1
float2 TDEHHash(float2 p)
{
    return frac(sin(mul(p, float2x2(127.1, 311.7, 269.5, 183.3))) * 43758.5453);
}
void TriangleGrid(float2 uv, out float w1, out float w2, out float w3, out float2 vertex1, out float2 vertex2, out float2 vertex3)
{
    uv *= 3.464;//2*sqrt(3)
    float2x2 gridToSkewedGrid = float2x2(1.0, 0.0, -0.57735027, 1.15470054);
    float2 skewedCoord = mul(gridToSkewedGrid, uv);
    int2 basedId = int2(floor(skewedCoord));
    float3 temp = float3(frac(skewedCoord), 0);
    temp.z = 1 - temp.x - temp.y;
    if(temp.z > 0)
    {
        w1 = temp.z;
        w2 = temp.y;
        w3 = temp.x;
        vertex1 = basedId;
        vertex2 = basedId + int2(0, 1);
        vertex3 = basedId + int2(1, 0);
    }else
    {
        w1 = -temp.z;
        w2 = 1 - temp.y;
        w3 = 1 - temp.x;
        vertex1 = basedId + int2(1, 1);
        vertex2 = basedId + int2(1, 0);
        vertex3 = basedId + int2(0, 1);
    }
}

float4 ProcedualTAB(TEXTURE2D_PARAM(tex, texSampler), float2 uv)
{
    float w1, w2, w3;
    float2 vertex1, vertex2, vertex3;
    TriangleGrid(uv, w1, w2, w3, vertex1, vertex2, vertex3);

    float2 uv1 = uv + TDEHHash(vertex1);
    float2 uv2 = uv + TDEHHash(vertex2);
    float2 uv3 = uv + TDEHHash(vertex3);

    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    float4 i1 = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv1, dx, dy);
    float4 i2 = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv2, dx, dy);
    float4 i3 = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv3, dx, dy);

    return w1 * i1 + w2 * i2 + w3 * i3;
}

//7 times
//compressionScaler -> 1, size = height,width, height ->1
float4 UnityProcedualTAB(TEXTURE2D_PARAM(tex, texSampler), float2 uv, float blendId/*, float compressionScaler*//*, float3 size*/)
{
    float w1, w2, w3;
    float2 vertex1, vertex2, vertex3;
    TriangleGrid(uv, w1, w2, w3, vertex1, vertex2, vertex3);

    float2 uv1 = uv + TDEHHash(vertex1);
    float2 uv2 = uv + TDEHHash(vertex2);
    float2 uv3 = uv + TDEHHash(vertex3);

    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    float4 i1 = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv1, dx, dy);
    float4 i2 = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv2, dx, dy);
    float4 i3 = SAMPLE_TEXTURE2D_GRAD(tex, texSampler, uv3, dx, dy);

    float exponent = 1.0 + blendId * 15.0;
    w1 = pow(w1, exponent);
    w2 = pow(w2, exponent);
    w3 = pow(w3, exponent);
    float sum = w1 + w2 + w3;
    w1 = w1 / sum;
    w2 = w2 / sum;
    w3 = w3 / sum;

    float4 G = w1 * i1 + w2 * i2 + w3 * i3;
    G = G - 0.5;
    G = G * rsqrt(w1 * w1 + w2 * w2 + w3 * w3);
    G = G * 1;
    G = G + 0.5;
    // return G;
    
    // dx *= size.xy;
    // dy *= size.xy;
    float delta_max_sqr = max(dot(dx, dx), dot(dy, dy));
    float mml = 0.5 * log2(delta_max_sqr);
    float LOD = max(0, mml) /*/ size.z*/;

    float4 result = 0;
    result.r = SAMPLE_TEXTURE2D_LOD(tex,texSampler, float2(G.r, LOD), 0).r;
    result.g = SAMPLE_TEXTURE2D_LOD(tex,texSampler, float2(G.g, LOD), 0).g;
    result.b = SAMPLE_TEXTURE2D_LOD(tex,texSampler, float2(G.b, LOD), 0).b;
    result.a = SAMPLE_TEXTURE2D_LOD(tex,texSampler, float2(G.a, LOD), 0).a;
    return result;
}
#endif