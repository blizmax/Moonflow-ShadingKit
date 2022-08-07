Shader"Moonflow/Test/GeometryToonGrass"
{
    Properties
    {
        _TopColor("Top Color", Color) = (0.7, 1, 0.7, 1)
        _BottomColor("Bottom Color", Color) = (0.2, 0.5, 0.2, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geo
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct appdata
            {
               float4 vertex : POSITION;
               float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2g
            {
               float4 vertex : SV_POSITION;
               float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            float4 _MainTex_ST;
            float4 _TopColor;
            float4 _BottomColor;

            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                o.normal = v.normal;
                o.tangent = v.tangent;
                return o;
            }
            
            struct g2f
            {
	            float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            g2f VertexOutput(float3 pos, float2 uv)
            {
	            g2f o;
	            o.pos = /*float4(pos, 1) + */TransformObjectToHClip(pos);
                o.uv = uv;
	            return o;
            }
            
            [maxvertexcount(3)]
            void geo(triangle v2g IN[3] : SV_POSITION, inout TriangleStream<g2f> triStream)
            {
                g2f o;
                
                float4 pos = IN[0].vertex;
                float3 vNormal = IN[0].normal;
                float4 vTangent = IN[0].tangent;
                float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

                
                
                float3x3 tangentToLocal = float3x3(
	                vTangent.x, vBinormal.x, vNormal.x,
	                vTangent.y, vBinormal.y, vNormal.y,
	                vTangent.z, vBinormal.z, vNormal.z
	                );
                triStream.Append(VertexOutput(pos + mul(tangentToLocal,float3(0.5, 0, 0)), float2(0,0)));
                triStream.Append(VertexOutput(pos + mul(tangentToLocal,float3(-0.5, 0, 0)), float2(1,0)));
                triStream.Append(VertexOutput(pos + mul(tangentToLocal,float3(0, 0, 1)), float2(0.5, 1)));
                // o.pos = pos + TransformObjectToHClip(float4(0.5, 0, 0, 1));
                // triStream.Append(o);
                //
                // o.pos = pos + TransformObjectToHClip(float4(-0.5, 0, 0, 1));
                // triStream.Append(o);
                //
                // o.pos = pos + TransformObjectToHClip(float4(0, 1, 0, 1));
                // triStream.Append(o);
            }
            
            half4 frag (g2f i) : SV_Target
            {
                // half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return lerp(_BottomColor, _TopColor, i.uv.y);
            }
            ENDHLSL
        }
    }
}
