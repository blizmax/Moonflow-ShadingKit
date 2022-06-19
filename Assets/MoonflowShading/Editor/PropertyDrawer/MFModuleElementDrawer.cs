using System;
using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFModuleElementDrawer : MaterialPropertyDrawer
    {
        private string _propertyName;
        private string _keywordName;
        private Material _mat;

        public MFModuleElementDrawer(string name)
        {
            _propertyName = name;
        }
        
        public MFModuleElementDrawer(string name, string keywordName)
        {
            _propertyName = name;
            _keywordName = keywordName;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (_mat != null && _mat.GetFloat(_propertyName) == 1f)
            {
                if (!string.IsNullOrEmpty(_keywordName) && !_mat.IsKeywordEnabled(_keywordName))
                {
                    return;
                }
                editor.DefaultShaderProperty(prop, label);
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
    }
}