Shader"Moonflow/CelBase"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _DiffuseTex ("Diffuse Tex", 2D) = "white" {}
        _NormalTex("Normal Tex", 2D) = "bump" {}
        _PBSTex("Data Tex", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma shader_feature MF_CEL_NORMALTEX
            #pragma vertex vert
            #pragma fragment frag
            #include "Library/MFCelBase.hlsl"
            

            half4 frag (Varying i) : SV_Target
            {
                half4 col = BaseShading(i);
                return col;
            }
            ENDHLSL
        }
    }
}
