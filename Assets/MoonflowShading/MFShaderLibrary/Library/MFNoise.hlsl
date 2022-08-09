#ifndef MF_NOISE_INCLUDED
#define MF_NOISE_INCLUDED
#include "MFHash.hlsl"

//https://iquilezles.org/articles/voronoilines/
float2 Noise_VoronoiOriginal(float2 x )
{
    int2 p = floor( x );
    float2  f = frac( x );

    float2 res = float2( 8.0, 8.0 );
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            int2 b = int2(i, j);
            float2 r = float2(b) - f + TDEHHash2D(p + b);//原文此处为一张2d noise采样
            float d = dot(r, r);

            if( d < res.x )
            {
                res.y = res.x;
                res.x = d;
            }
            else if( d < res.y )
            {
                res.y = d;
            }
        }
    return sqrt( res );
}

//https://iquilezles.org/articles/voronoilines/
float Noise_VoronoiDistance( float2 x )
{
    int2 p = int2(floor( x ));
    float2  f = frac( x );

    int2 mb;
    float2 mr;

    float res = 8.0;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            int2 b = int2(i, j);
            float2  r = float2(b) + TDEHHash2D(p+b)-f;//原文此处为一张2d noise采样
            float d = dot(r,r);

            if( d < res )
            {
                res = d;
                mr = r;
                mb = b;
            }
        }

    res = 8.0;
    for( int j=-2; j<=2; j++ )
        for( int i=-2; i<=2; i++ )
        {
            int2 b = mb + int2(i, j);
            float2  r = float2(b) + TDEHHash2D(p+b) - f;
            float d = dot(0.5*(mr+r), normalize(r-mr));

            res = min( res, d );
        }
    return res;
}

//https://iquilezles.org/articles/smoothvoronoi/
float Noise_SmoothVoronoiSimple( in float2 x )
{
    int2 p = floor( x );
    float2  f = frac( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            int2 b = int2( i, j );
            float2  r = float2( b ) - f + hash2D( p + b );
            float d = dot( r, r );

            res += 1.0/pow( d, 8.0 );
        }
    return pow( 1.0/res, 1.0/16.0 );
}
//https://iquilezles.org/articles/smoothvoronoi/
float Noise_SmoothVoronoi( in float2 x )
{
    int2 p = floor( x );
    float2  f = frac( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            int2 b = int2( i, j );
            float2  r = float2( b ) - f + hash2D( p + b );
            float d = length( r );

            res += exp2( -32.0*d );
        }
    return -(1.0/32.0)*log2( res );
}

float3 mod2D289 ( float3 x ) { return x - floor ( x * ( 1.0 / 289.0 ) ) * 289.0; }
float2 mod2D289 ( float2 x ) { return x - floor ( x * ( 1.0 / 289.0 ) ) * 289.0; }
float3 mod3D289 ( float3 x ) { return x - floor ( x / 289.0 ) * 289.0; }
float4 mod3D289 ( float4 x ) { return x - floor ( x / 289.0 ) * 289.0; }
float3 permute ( float3 x ) { return mod2D289 ( ( ( x * 34.0 ) + 1.0 ) * x ); }
float4 permute ( float4 x ) { return mod3D289 ( ( x * 34.0 + 1.0 ) * x ); }
float4 taylorInvSqrt ( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

float Noise_Simplex2D ( float2 v )
{
    const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
    float2 i = floor ( v + dot ( v, C.yy ) );
    float2 x0 = v - i + dot ( i, C.xx );
    float2 i1;
    i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod2D289 ( i );
    float3 p = permute ( permute ( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
    float3 m = max ( 0.5 - float3( dot ( x0, x0 ), dot ( x12.xy, x12.xy ), dot ( x12.zw, x12.zw ) ), 0.0 );
    m = m * m;
    m = m * m;
    float3 x = 2.0 * frac ( p * C.www ) - 1.0;
    float3 h = abs ( x ) - 0.5;
    float3 ox = floor ( x + 0.5 );
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot ( m, g );
}

float Noise_Simplex3D ( float3 v )
{
    const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
    float3 i = floor ( v + dot ( v, C.yyy ) );
    float3 x0 = v - i + dot ( i, C.xxx );
    float3 g = step ( x0.yzx, x0.xyz );
    float3 l = 1.0 - g;
    float3 i1 = min ( g.xyz, l.zxy );
    float3 i2 = max ( g.xyz, l.zxy );
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - 0.5;
    i = mod3D289 ( i );
    float4 p = permute ( permute ( permute ( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
    float4 j = p - 49.0 * floor ( p / 49.0 );  // mod(p,7*7)
    float4 x_ = floor ( j / 7.0 );
    float4 y_ = floor ( j - 7.0 * x_ );  // mod(j,N)
    float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
    float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
    float4 h = 1.0 - abs ( x ) - abs ( y );
    float4 b0 = float4( x.xy, y.xy );
    float4 b1 = float4( x.zw, y.zw );
    float4 s0 = floor ( b0 ) * 2.0 + 1.0;
    float4 s1 = floor ( b1 ) * 2.0 + 1.0;
    float4 sh = -step ( h, 0.0 );
    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    float3 g0 = float3( a0.xy, h.x );
    float3 g1 = float3( a0.zw, h.y );
    float3 g2 = float3( a1.xy, h.z );
    float3 g3 = float3( a1.zw, h.w );
    float4 norm = taylorInvSqrt ( float4( dot ( g0, g0 ), dot ( g1, g1 ), dot ( g2, g2 ), dot ( g3, g3 ) ) );
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;
    float4 m = max ( 0.6 - float4( dot ( x0, x0 ), dot ( x1, x1 ), dot ( x2, x2 ), dot ( x3, x3 ) ), 0.0 );
    m = m* m;
    m = m* m;
    float4 px = float4( dot ( x0, g0 ), dot ( x1, g1 ), dot ( x2, g2 ), dot ( x3, g3 ) );
    return 42.0 * dot ( m, px );
}

float2 GradientNoiseDir (float2 x)
{
    const float2 k = float2(0.3183099, 0.3678794);
    x = x * k + k.yx;
    return -1.0 + 2.0 * frac (16.0 * k * frac (x.x * x.y * (x.x + x.y)));
}

float Noise_Gradient2D (float2 UV, float Scale)
{
    float2 p = UV * Scale;
    float2 i = floor (p);
    float2 f = frac (p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp (lerp (dot (GradientNoiseDir (i + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
            dot (GradientNoiseDir (i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
            lerp (dot (GradientNoiseDir (i + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
            dot (GradientNoiseDir (i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
}

float Noise_Value2D (float2 UV, float Scale)
{
    float2 p = UV * Scale;
    float2 i = floor (p);
    float2 f = frac (p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp (lerp (hash2D (i + float2(0.0, 0.0)),
                        hash2D (i + float2(1.0, 0.0)), u.x),
                lerp (hash2D (i + float2(0.0, 1.0)),
                        hash2D (i + float2(1.0, 1.0)), u.x), u.y);
}

#endif