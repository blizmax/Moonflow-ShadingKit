#ifndef MF_CEL_LIGHTING_INCLUDED
#define MF_CEL_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "MFCelShadow.hlsl"
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float, _ShadowStr)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct MFLightData
{
    float3 lightDir;
    float3 lightColor;
    float lightAtten;
    float shadowAtten;
    float NdL;
    float NdLpost;
    float VdL;
    float3 h;
    float NdH;
    float LdH;
    float VdH;
    float falloff;
    // float lightMask;
    
};

float3 GetSpecular(Varying i, MFMatData matData, MFLightData lightData)
{
    float3 lightDirectionWSFloat3 = float3(lightData.lightDir);
    float3 halfDir = SafeNormalize(lightDirectionWSFloat3 + float3(matData.viewDirWS));

    float NoH = saturate(dot(float3(i.normalWS), halfDir));
    half LoH = half(saturate(dot(lightDirectionWSFloat3, halfDir)));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * (1 - matData.roughness2) + 1.00001f;
    half d2 = half(d * d);

    half LoH2 = LoH * LoH;
    half specularTerm = matData.roughness2 / (d2 * max(half(0.1), LoH2) * (matData.roughness * 4 + 2 ));

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
    #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
    #endif

    return specularTerm * matData.specColor;
}

MFLightData GetLightingData(Varying i, MFMatData matData)
{
    MFLightData ld;
    Light mainLight = GetMainLight(i.shadowCoord);
    ld.lightDir = mainLight.direction;
    ld.lightColor = mainLight.color;
    ld.shadowAtten = mainLight.shadowAttenuation * _ShadowStr + 1-_ShadowStr;
    ld.NdL = dot(i.normalWS, ld.lightDir);
    ld.lightAtten = max(0,ld.NdL);
    ld.NdLpost = saturate(ld.NdL);
    ld.VdL = dot(matData.viewDirWS, ld.lightDir);
    ld.h = normalize(ld.lightDir + matData.viewDirWS);
    ld.NdH = dot(i.normalWS, ld.h);
    ld.LdH = dot(ld.lightDir, ld.h);
    ld.VdH = dot(matData.viewDirWS, ld.h);
    return ld;
    // ld.lightMask = saturate(ld.NdLpost * shadow)
}

void CelLight(Varying i, MFMatData matData, MFLightData lightData, out float3 diffuse, out float3 specular, out float3 GI)
{
    float shadow = GetShadow(i, matData);
    shadow = CelShadow(i, shadow, lightData.lightDir, lightData.shadowAtten);

    diffuse = matData.diffuse;
    diffuse *= lightData.lightColor * lightData.lightAtten;
    specular = GetSpecular(i, matData, lightData) * shadow;
    specular = specular * lightData.lightColor * lightData.lightAtten;
    GI = SAMPLE_GI(i.lightmapUV, i.vertexSH, i.normalWS) * matData.diffuse;
}

#endif