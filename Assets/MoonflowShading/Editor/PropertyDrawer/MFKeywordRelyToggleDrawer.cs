using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFKeywordRelyToggleDrawer: MaterialPropertyDrawer
    {
        private string _relyKeyword;
        private Material _mat;
        private bool toggle;

        public MFKeywordRelyToggleDrawer(string keyword)
        {
            _relyKeyword = keyword;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (_mat != null && _mat.IsKeywordEnabled(_relyKeyword))
            { 
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = prop.hasMixedValue;
                toggle = prop.floatValue == 1f;
                toggle = EditorGUI.Toggle(MFShaderGUIUtility.GetRect(prop), prop.displayName, toggle);
                EditorGUI.showMixedValue = false;
                if (EditorGUI.EndChangeCheck())
                {
                    prop.floatValue = toggle ? 1f : 0f;
                }
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
    }
}