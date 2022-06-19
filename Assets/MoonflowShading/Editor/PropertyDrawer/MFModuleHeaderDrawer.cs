using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFModuleHeaderDrawer: MaterialPropertyDrawer
    {
        private string title;
        private GUIStyle _moduleTitle = new GUIStyle()
        {
            // border = new RectOffset(5,5,5,5),
            padding = new RectOffset(5,5,0,0),
            margin =  new RectOffset(0,0,20,0),
            fontSize = 14, 
            fontStyle = FontStyle.Bold,
            normal = new GUIStyleState()
            {
                textColor = Color.white,
                background = MFLoadManager.Load<Texture2D>(new MFResInfo("moonflowBanner",""), true)
            },
        };

        public MFModuleHeaderDrawer(string t)
        {
            title = t;
        }
 
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            EditorGUI.LabelField(MFShaderGUIUtility.GetRect(prop), "▣ "+title, _moduleTitle);
            editor.DefaultShaderProperty(prop,label);
        }
        
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 18f;
        }
        
    }
}