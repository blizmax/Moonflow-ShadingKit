
using UnityEditor;
using UnityEngine;

public class MFShaderBaseModule :MFShaderModuleScope
{
    public MFShaderBaseModule(uint index, MaterialEditor editor) : base(index, editor)
    {
        titleContent = EditorGUIUtility.TrTextContent("Base", "基础功能");
    }

    public override void DrawEditor(Material material)
    {
        
        DoSet();
    }

    public override void FindProperties(MaterialProperty[] properties)
    {
        throw new System.NotImplementedException();
    }

    public void DoSet()
    {
        throw new System.NotImplementedException();
    }
}
