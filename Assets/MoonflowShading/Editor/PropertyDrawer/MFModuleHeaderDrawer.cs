using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFModuleHeaderDrawer: MaterialPropertyDrawer
    {
        private string title;
        public MFModuleHeaderDrawer(string t)
        {
            title = t;
        }
 
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            EditorGUI.LabelField(MFShaderGUIUtility.GetRect(prop), "▣ "+ title, MFShaderGUIConfig.GetInstance().ModuleTitle);
            editor.DefaultShaderProperty(prop,label);
        }
        
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
        
    }
}