//https://iquilezles.org/articles/distfunctions/
#ifndef MF_SHAPE_INCLUDED
#define MF_SHAPE_INCLUDED
#include "MFUtility.hlsl"

//Sphere - exact
float sdSphere( float3 p, float s )
{
    return length(p)-s;
}

//Box - exact
float sdBox( float3 p, float3 b )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

//Round Box - exact
float sdRoundBox( float3 p, float3 b, float r )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

//Box Frame - exact
float sdBoxFrame( float3 p, float3 b, float e )
{
    p = abs(p)-b;
    float3 q = abs(p+e)-e;
    return min(min(
        length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
        length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
        length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

//Torus - exact
float sdTorus( float3 p, float2 t )
{
    float2 q = float2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

//Capped Torus - exact
float sdCappedTorus( float3 p,  float2 sc,  float ra,  float rb)
{
    p.x = abs(p.x);
    float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
    return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

//Link - exact
float sdLink( float3 p, float le, float r1, float r2 )
{
    float3 q = float3( p.x, max(abs(p.y)-le,0.0), p.z );
    return length(float2(length(q.xy)-r1,q.z)) - r2;
}

//Infinite Cylinder - exact
float sdCylinder( float3 p, float3 c )
{
    return length(p.xz-c.xy)-c.z;
}

//Cone - exact
float sdCone( float3 p, float2 c, float h )
{
    // c is the sin/cos of the angle, h is height
    // Alternatively pass q instead of (c,h),
    // which is the point at the base in 2D
    float2 q = h*float2(c.x/c.y,-1.0);
    
    float2 w = float2( length(p.xz), p.y );
    float2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
    float2 b = w - q*float2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
    float k = sign( q.y );
    float d = min(dot( a, a ),dot(b, b));
    float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
    return sqrt(d)*sign(s);
}

//Cone - bound (not exact!)
float sdConeBound( float3 p, float2 c, float h )
{
    float q = length(p.xz);
    return max(dot(c.xy,float2(q,p.y)),-h-p.y);
}

//Infinite Cone - exact
float sdConeInfinite( float3 p, float2 c )
{
    // c is the sin/cos of the angle
    float2 q = float2( length(p.xz), -p.y );
    float d = length(q-c*max(dot(q,c), 0.0));
    return d * ((q.x*c.y-q.y*c.x<0.0)?-1.0:1.0);
}

//Plane - exact
float sdPlane( float3 p, float3 n, float h )
{
    // n must be normalized
    return dot(p,n) + h;
}

//Hexagonal Prism - exact
float sdHexPrism( float3 p, float2 h )
{
    const float3 k = float3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
    float2 d = float2(
         length(p.xy-float2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
         p.z-h.y );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//Triangular Prism - bound
float sdTriPrism( float3 p, float2 h )
{
    float3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

//Capsule / Line - exact
float sdCapsule( float3 p, float3 a, float3 b, float r )
{
    float3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

//Capsule / Line - exact
float sdVerticalCapsule( float3 p, float h, float r )
{
    p.y -= clamp( p.y, 0.0, h );
    return length( p ) - r;
}

//Capped Cylinder - exact
float sdCappedCylinder( float3 p, float h, float r )
{
    float2 d = abs(float2(length(p.xz),p.y)) - float2(h,r);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//Capped Cylinder - exact
float sdCappedCylinder(float3 p, float3 a, float3 b, float r)
{
    float3  ba = b - a;
    float3  pa = p - a;
    float baba = dot(ba,ba);
    float paba = dot(pa,ba);
    float x = length(pa*baba-ba*paba) - r*baba;
    float y = abs(paba-baba*0.5)-baba*0.5;
    float x2 = x*x;
    float y2 = y*y*baba;
    float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
    return sign(d)*sqrt(abs(d))/baba;
}

//Rounded Cylinder - exact
float sdRoundedCylinder( float3 p, float ra, float rb, float h )
{
    float2 d = float2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}

//Capped Cone - exact
float sdCappedCone( float3 p, float h, float r1, float r2 )
{
    float2 q = float2( length(p.xz), p.y );
    float2 k1 = float2(r2,h);
    float2 k2 = float2(r2-r1,2.0*h);
    float2 ca = float2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
    float2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot2(ca),dot2(cb)) );
}

//Capped Cone - exact   (https://www.shadertoy.com/view/tsSXzK)
float sdCappedCone(float3 p, float3 a, float3 b, float ra, float rb)
{
    float rba  = rb-ra;
    float baba = dot(b-a,b-a);
    float papa = dot(p-a,p-a);
    float paba = dot(p-a,b-a)/baba;
    float x = sqrt( papa - paba*paba*baba );
    float cax = max(0.0,x-((paba<0.5)?ra:rb));
    float cay = abs(paba-0.5)-0.5;
    float k = rba*rba + baba;
    float f = clamp( (rba*(x-ra)+paba*baba)/k, 0.0, 1.0 );
    float cbx = x-ra - f*rba;
    float cby = paba - f;
    float s = (cbx<0.0 && cay<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(cax*cax + cay*cay*baba,
                       cbx*cbx + cby*cby*baba) );
}

//Solid Angle - exact   (https://www.shadertoy.com/view/wtjSDW)
float sdSolidAngle(float3 p, float2 c, float ra)
{
    // c is the sin/cos of the angle
    float2 q = float2( length(p.xz), p.y );
    float l = length(q) - ra;
    float m = length(q - c*clamp(dot(q,c),0.0,ra) );
    return max(l,m*sign(c.y*q.x-c.x*q.y));
}

//Cut Sphere - exact   (https://www.shadertoy.com/view/stKSzc)
float sdCutSphere( float3 p, float r, float h )
{
    // sampling independent computations (only depend on shape)
    float w = sqrt(r*r-h*h);

    // sampling dependant computations
    float2 q = float2( length(p.xz), p.y );
    float s = max( (h-r)*q.x*q.x+w*w*(h+r-2.0*q.y), h*q.x-w*q.y );
    return (s<0.0) ? length(q)-r :
           (q.x<w) ? h - q.y     :
                     length(q-float2(w,h));
}

//Cut Hollow Sphere - exact   (https://www.shadertoy.com/view/7tVXRt)
float sdCutHollowSphere( float3 p, float r, float h, float t )
{
    // sampling independent computations (only depend on shape)
    float w = sqrt(r*r-h*h);
  
    // sampling dependant computations
    float2 q = float2( length(p.xz), p.y );
    return ((h*q.x<w*q.y) ? length(q-float2(w,h)) : 
                            abs(length(q)-r) ) - t;
}

//Death Star - exact   (https://www.shadertoy.com/view/7lVXRt)
float sdDeathStar(  float3 p2,  float ra, float rb,  float d )
{
    // sampling independent computations (only depend on shape)
    float a = (ra*ra - rb*rb + d*d)/(2.0*d);
    float b = sqrt(max(ra*ra-a*a,0.0));
	
    // sampling dependant computations
    float2 p = float2( p2.x, length(p2.yz) );
    if( p.x*b-p.y*a > d*max(b-p.y,0.0) )
        return length(p-float2(a,b));
    else
        return max( (length(p          )-ra),
                   -(length(p-float2(d,0))-rb));
}

//Round cone - exact
float sdRoundCone( float3 p, float r1, float r2, float h )
{
    // sampling independent computations (only depend on shape)
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);

    // sampling dependant computations
    float2 q = float2( length(p.xz), p.y );
    float k = dot(q,float2(-b,a));
    if( k<0.0 ) return length(q) - r1;
    if( k>a*h ) return length(q-float2(0.0,h)) - r2;
    return dot(q, float2(a,b) ) - r1;
}

//Round Cone - exact   (https://www.shadertoy.com/view/tdXGWr)
float sdRoundCone(float3 p, float3 a, float3 b, float r1, float r2)
{
    // sampling independent computations (only depend on shape)
    float3  ba = b - a;
    float l2 = dot(ba,ba);
    float rr = r1 - r2;
    float a2 = l2 - rr*rr;
    float il2 = 1.0/l2;
    
    // sampling dependant computations
    float3 pa = p - a;
    float y = dot(pa,ba);
    float z = y - l2;
    float x2 = dot2( pa*l2 - ba*y );
    float y2 = y*y*l2;
    float z2 = z*z*l2;

    // single square root!
    float k = sign(rr)*rr*rr*x2;
    if( sign(z)*a2*z2>k ) return  sqrt(x2 + z2)        *il2 - r2;
    if( sign(y)*a2*y2<k ) return  sqrt(x2 + y2)        *il2 - r1;
    return (sqrt(x2*a2*il2)+y*rr)*il2 - r1;
}

//Ellipsoid - bound (not exact!)   (https://www.shadertoy.com/view/tdS3DG)
float sdEllipsoid( float3 p, float3 r )
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

//Rhombus - exact   (https://www.shadertoy.com/view/tlVGDc)
float sdRhombus(float3 p, float la, float lb, float h, float ra)
{
    p = abs(p);
    float2 b = float2(la,lb);
    float f = clamp( (ndot(b,b-2.0*p.xz))/dot(b,b), -1.0, 1.0 );
    float2 q = float2(length(p.xz-0.5*b*float2(1.0-f,1.0+f))*sign(p.x*b.y+p.z*b.x-b.x*b.y)-ra, p.y-h);
    return min(max(q.x,q.y),0.0) + length(max(q,0.0));
}

//Octahedron - exact   (https://www.shadertoy.com/view/wsSGDG)
float sdOctahedron( float3 p, float s)
{
    p = abs(p);
    float m = p.x+p.y+p.z-s;
    float3 q;
    if( 3.0*p.x < m ) q = p.xyz;
    else if( 3.0*p.y < m ) q = p.yzx;
    else if( 3.0*p.z < m ) q = p.zxy;
    else return m*0.57735027;
    
    float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
    return length(float3(q.x,q.y-s+k,q.z-k)); 
}

//Octahedron - bound (not exact)
float sdOctahedronBound( float3 p, float s)
{
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
}

//Pyramid - exact   (https://www.shadertoy.com/view/Ws3SDl)
float sdPyramid( float3 p, float h)
{
  float m2 = h*h + 0.25;
    
  p.xz = abs(p.xz);
  p.xz = (p.z>p.x) ? p.zx : p.xz;
  p.xz -= 0.5;

  float3 q = float3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
   
  float s = max(-q.x,0.0);
  float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
  float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
  float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
  float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
  return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
}

//Triangle - exact   (https://www.shadertoy.com/view/4sXXRN)
float udTriangle( float3 p, float3 a, float3 b, float3 c )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 ac = a - c; float3 pc = p - c;
    float3 nor = cross( ba, ac );

    return sqrt(
      (sign(dot(cross(ba,nor),pa)) +
       sign(dot(cross(cb,nor),pb)) +
       sign(dot(cross(ac,nor),pc))<2.0)
       ?
       min( min(
       dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
       dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
       dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
       :
       dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

//Quad - exact   (https://www.shadertoy.com/view/Md2BWW)
float udQuad( float3 p, float3 a, float3 b, float3 c, float3 d )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 dc = d - c; float3 pc = p - c;
    float3 ad = a - d; float3 pd = p - d;
    float3 nor = cross( ba, ad );

    return sqrt(
      (sign(dot(cross(ba,nor),pa)) +
       sign(dot(cross(cb,nor),pb)) +
       sign(dot(cross(dc,nor),pc)) +
       sign(dot(cross(ad,nor),pd))<3.0)
       ?
       min( min( min(
       dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
       dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
       dot2(dc*clamp(dot(dc,pc)/dot2(dc),0.0,1.0)-pc) ),
       dot2(ad*clamp(dot(ad,pd)/dot2(ad),0.0,1.0)-pd) )
       :
       dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

// float opRound( function 3DsdfPrimitive, float rad )
// {
//     return 3DsdfPrimitive(p) - rad
// }

float opOnion( float sdf, float thickness )
{
    return abs(sdf)-thickness;
}

// float opExtrusion( float3 p, function 2dPrimitive, in float h )
// {
//     float d = 2dPrimitive(p.xy)
//     vec2 w = vec2( d, abs(p.z) - h );
//     return min(max(w.x,w.y),0.0) + length(max(w,0.0));
// }

// float opRevolution( float3 p, function 2dPrimitive, float o )
// {
//     vec2 q = vec2( length(p.xz) - o, p.y );
//     return 2dPrimitive(q)
// }

float length2( float3 p ) { p=p*p; return sqrt( p.x+p.y+p.z); }

float length6( float3 p ) { p=p*p*p; p=p*p; return pow(p.x+p.y+p.z,1.0/6.0); }

float length8( float3 p ) { p=p*p; p=p*p; p=p*p; return pow(p.x+p.y+p.z,1.0/8.0); }

float opUnion( float d1, float d2 ) { return min(d1,d2); }

float opSubtraction( float d1, float d2 ) { return max(-d1,d2); }

float opIntersection( float d1, float d2 ) { return max(d1,d2); }

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); }

// float3 opTx( float3 p, transform t, function 3Dprimitive )
// {
//     return 3Dprimitive( invert(t)*p );
// }
//
// float opScale( float3 p, float s, function 3Dprimitive )
// {
//     return 3Dprimitive(p/s)*s;
// }
//
// float opSymX( float3 p, function 3Dprimitive )
// {
//     p.x = abs(p.x);
//     return 3Dprimitive(p);
// }
//
// float opSymXZ( float3 p, function 3Dprimitive )
// {
//     p.xz = abs(p.xz);
//     return 3Dprimitive(p);
// }

// float3 opRepLim( float3 p, float c, float3 l, function 3Dprimitive )
// {
//     float3 q = p-c*clamp(round(p/c),-l,l);
//     return 3Dprimitive( q );
// }

// float opDisplace( function 3Dprimitive, float3 p )
// {
//     float d1 = 3Dprimitive(p);
//     float d2 = displacement(p);
//     return d1+d2;
// }

// float opTwist( function 3Dprimitive, float3 p )
// {
//     const float k = 10.0; // or some other amount
//     float c = cos(k*p.y);
//     float s = sin(k*p.y);
//     mat2  m = mat2(c,-s,s,c);
//     float3  q = float3(m*p.xz,p.y);
//     return 3Dprimitive(q);
// }
//
// float opCheapBend( function primitive, float3 p )
// {
//     const float k = 10.0; // or some other amount
//     float c = cos(k*p.x);
//     float s = sin(k*p.x);
//     mat2  m = mat2(c,-s,s,c);
//     float3  q = float3(m*p.xy,p.z);
//     return 3Dprimitive(q);
// }

#endif