Shader"Moonflow/Demo/Palettes"
{
    Properties
    {
        _ColorA("Color A", Color) = (0.5,0.5,0.5, 1)
        _ColorB("Color B", Color) = (0.5,0.5,0.5, 1)
        _ColorC("Color C", Color) = (0.5,0.5,0.5, 1)
        _Mix("Mix", Vector) = (0, 0.33, 0.67, 0)
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "../../MFShaderLibrary/Library/MFUtility.hlsl"

            struct appdata
            {
               float4 vertex : POSITION;
               float2 uv : TEXCOORD0;
            };

            struct v2f
            {
               float4 vertex : SV_POSITION;
               float2 uv : TEXCOORD0;
            };

            
            float3 _ColorA;
            float3 _ColorB;
            float3 _ColorC;
            float3 _Mix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 col = Palettes(i.uv.x, _ColorA, _ColorB, _ColorC, _Mix);
                return float4(col,1);
            }
            ENDHLSL
        }
    }
}
