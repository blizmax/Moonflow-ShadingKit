using System;
using UnityEditor;
using UnityEngine;


public class MFShaderRenderOptionModule: MFShaderModuleScope
{
    public MaterialProperty renderTypeProp;
    public MaterialProperty blendModeProp;
    private GUIContent _renderTypeContent;
    private GUIContent _blendModeContent;
    public MFShaderRenderOptionModule(uint index, MaterialEditor editor) : base(index, editor)
    {
        materialEditor = editor;
        titleContent = EditorGUIUtility.TrTextContent("Render Option", "设置渲染属性");
        _renderTypeContent = EditorGUIUtility.TrTextContent("Render Type", "设置渲染类型");
        _blendModeContent = EditorGUIUtility.TrTextContent("Blend Mode", "设置混合属性");
    }

    public override void DrawEditor(Material material)
    {
        using (new EditorGUILayout.VerticalScope("box"))
        {
            mat = material;
            materialEditor.MFDrawMatPopup(_renderTypeContent, renderTypeProp,
                Enum.GetNames(typeof(BaseShaderGUI.SurfaceType)));
            if ((BaseShaderGUI.SurfaceType)renderTypeProp.floatValue != BaseShaderGUI.SurfaceType.Opaque)
            {
                materialEditor.MFDrawMatPopup(_blendModeContent, blendModeProp,
                    Enum.GetNames(typeof(BaseShaderGUI.BlendMode)));
            }
            DoSet();
        }
    }

    public override void FindProperties(MaterialProperty[] properties)
    {
        renderTypeProp = FindProperty("_rendertype", properties, false);
        blendModeProp = FindProperty("_blendmode", properties, false);
    }

    public void DoSet()
    {
        BaseShaderGUI.SurfaceType rendertype = (BaseShaderGUI.SurfaceType)renderTypeProp.floatValue;
        if (rendertype == BaseShaderGUI.SurfaceType.Opaque)
        {
            mat.renderQueue = 2000;
            mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
            mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
            return;
        }
        mat.renderQueue = 3000;
        BaseShaderGUI.BlendMode mode = (BaseShaderGUI.BlendMode)blendModeProp.floatValue;
        switch (mode)
        {
            case BaseShaderGUI.BlendMode.Alpha:
                //mat.DisableKeyword("_ADD_BLEND");
                //mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                mat.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                mat.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;                
            case BaseShaderGUI.BlendMode.Additive:
                //mat.EnableKeyword("_ADD_BLEND");
                //mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                mat.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                mat.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                break;
            case BaseShaderGUI.BlendMode.Multiply:
                //mat.EnableKeyword("_ADD_BLEND");
                mat.SetOverrideTag("RenderType", "Transparent");
                //mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.ReverseSubtract);
                mat.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                mat.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                break;
            case BaseShaderGUI.BlendMode.Premultiply:
                //mat.DisableKeyword("_ADD_BLEND");
                //mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                mat.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                mat.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                break;
            default:
                mat.SetFloat("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                mat.SetFloat("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                break;
        }
    }
}
