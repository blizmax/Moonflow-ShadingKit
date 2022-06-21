using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;


public class MFCelShaderGUI : MFShaderGUI
{
    public uint materialFilter => uint.MaxValue;

    private MaterialEditor _materialEditor;
    private Material _material;
    private bool _hasInit = false;
    [Flags]
    protected enum MFCelExpand
    {
        RenderOption = 1 << 0,
        FeatureOption = 1 << 1,
        Base = 1 << 2,
        Specular = 1 << 3,
        Reflection = 1 << 4,
        GI = 1 << 5,
    }

    // private MFShaderModuleScope[] _shaderModuleScope;
    private MaterialHeaderScopeList m_MaterialScopeList =
        new MaterialHeaderScopeList(uint.MaxValue & ~(uint)MFCelExpand.GI);

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        _materialEditor = materialEditor;
        _material = materialEditor.target as Material;
        
        if (!_hasInit)
        {
            Register(_material, _materialEditor);
            _hasInit = true;
        }

        DrawTitle(_materialEditor);
        FindProperties(properties);
        OnTopGUI(materialEditor, properties);
        DrawGUI();
        base.OnGUI(materialEditor, properties);
        OnBottomGUI(materialEditor, properties);
    }

    private void DrawGUI()
    {
        m_MaterialScopeList.DrawHeaders(_materialEditor, _material);
    }

    private void Register(Material material, MaterialEditor materialEditor)
    {
        // _shaderModuleScope = new[]
        // {
        //     new MFShaderRenderOptionModule((uint)MFCelExpand.RenderOption, _materialEditor),
        // };
        var filter = materialFilter;
        // for (int i = 0; i < _shaderModuleScope.Length; i++)
        // {
        //     _shaderModuleScope[i].MFShaderModuleScopeRegister(filter, ref m_MaterialScopeList);
        // }
    }

    public override void FindProperties(MaterialProperty[] properties)
    {
        base.FindProperties(properties);
        var material = _materialEditor?.target as Material;
        if (material == null)
            return;

        // for (int i = 0; i < _shaderModuleScope.Length; i++)
        // {
        //     _shaderModuleScope[i].FindProperties(properties);
        // }
    }
}
