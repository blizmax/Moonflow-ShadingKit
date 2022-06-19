using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFModuleDefinition: MaterialPropertyDrawer
    {
        private string _relyKeyword;
        private Material _mat;
        private bool toggle;
        private bool enabled;
        
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

        public MFModuleDefinition(string keyword)
        {
            _relyKeyword = keyword;
        }
        public MFModuleDefinition()
        {
            _relyKeyword = "";
        }
 
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            
            _mat = editor.target as Material;
            if (_mat != null)
            {
                if (!string.IsNullOrEmpty(_relyKeyword))
                {
                    enabled = _mat.IsKeywordEnabled(_relyKeyword);
                    _mat.SetFloat(prop.name, enabled ? 1 : 0);
                    if (enabled)
                    {
                        EditorGUI.LabelField(MFShaderGUIUtility.GetRect(prop), "▣ "+prop.displayName, _moduleTitle);
                    }
                }
                else
                {
                    enabled = true;
                    EditorGUI.BeginChangeCheck();
                    EditorGUI.showMixedValue = prop.hasMixedValue;
                    toggle = prop.floatValue == 1f;
                    toggle = EditorGUI.ToggleLeft(MFShaderGUIUtility.GetRect(prop), prop.displayName, toggle, _moduleTitle);
                    EditorGUI.showMixedValue = false;
                    if (EditorGUI.EndChangeCheck())
                    {
                        prop.floatValue = toggle ? 1f : 0f;
                    }
                }
                
            }
        }
        
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return enabled ? 18f: 0;
        }
        
    }
}