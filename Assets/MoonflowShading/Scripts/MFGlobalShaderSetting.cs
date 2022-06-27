using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class MFGlobalShaderSetting : MonoBehaviour
{
    [Header("RimLight")] 
    public float RimFadeDistance = 10;
    [Range(0, 1)] public float perspectiveCorrection = 0.5f;
    
    private static readonly int RIM_FADE_DISTANCE = Shader.PropertyToID("_RimFadeDistance");
    private static readonly int PERSPECTIVE_CORRECTION = Shader.PropertyToID("_PerspectiveCorrection");

    private void Update()
    {
        Shader.SetGlobalFloat(RIM_FADE_DISTANCE, RimFadeDistance);
        Shader.SetGlobalFloat(PERSPECTIVE_CORRECTION, perspectiveCorrection);
    }
}
