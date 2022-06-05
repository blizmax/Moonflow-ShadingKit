using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MFShaderGUI : ShaderGUI
{
    private string keywords;
    // public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    // {
    //     base.OnGUI(materialEditor, properties);
    // }

    protected void OnTopGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material targetMat = materialEditor.target as Material;
        MakeKeywordList(targetMat.shaderKeywords);
    }

    private void MakeKeywordList(string[] keywordArr)
    {
        keywords = "";
        for (int i = 0; i < keywordArr.Length; i++)
        {
            keywords += keywordArr[i] + " ";
            if (i != keywordArr.Length - 1)
            {
                keywords += " | ";
            }
        }
        using (new EditorGUILayout.VerticalScope("box"))
        {
            EditorGUILayout.LabelField("Current Keywords：");
            EditorGUILayout.SelectableLabel(keywords, EditorStyles.textField, GUILayout.Height(EditorGUIUtility.singleLineHeight));
        }
    }

    public virtual void FindProperties(MaterialProperty[] properties)
    {
        
    }
}
