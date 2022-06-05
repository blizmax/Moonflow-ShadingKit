using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;


public abstract class MFShaderModuleScope
{
    public MaterialEditor materialEditor;
    protected uint expandIndex;
    protected GUIContent titleContent;

    public uint ExpandIndex => expandIndex;
    public GUIContent TitleContent => titleContent;

    public MFShaderModuleScope(uint index, MaterialEditor editor)
    {
        expandIndex = index;
        materialEditor = editor;
    }

    public abstract void DrawEditor(Material material);
    public abstract void FindProperties(MaterialProperty[] properties);
    public static MaterialProperty FindProperty(string propertyName, MaterialProperty[] properties, bool propertyIsMandatory)
    {
        for (int index = 0; index < properties.Length; ++index)
        {
            if (properties[index] != null && properties[index].name == propertyName)
                return properties[index];
        }
        if (propertyIsMandatory)
            throw new ArgumentException("Could not find MaterialProperty: '" + propertyName + "', Num properties: " + (object)properties.Length);
        return null;
    }

    public abstract void DoSet();

}
