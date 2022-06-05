using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;


public static class MFShaderGUIUtility
{
    public static void MFDrawMatPopup(this MaterialEditor materialEditor, GUIContent label, MaterialProperty property, string[] options)
    {
        if (property != null)
            materialEditor.PopupShaderProperty(property, label, options);
    }

    public static void MFShaderModuleScopeRegister(this MFShaderModuleScope scope, uint filter, ref MaterialHeaderScopeList scopeList)
    {
        if ((filter & scope.ExpandIndex) != 0 )
        {
            scopeList.RegisterHeaderScope(scope.TitleContent, scope.ExpandIndex, scope.DrawEditor);
        }
    }
}
