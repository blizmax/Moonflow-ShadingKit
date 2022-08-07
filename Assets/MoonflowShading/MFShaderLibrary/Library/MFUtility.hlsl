#ifndef MF_UTILITY_INCLUDED
#define MF_UTILITY_INCLUDED

float3 Palettes(float t, float3 a, float3 b, float3 c, float3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

#endif