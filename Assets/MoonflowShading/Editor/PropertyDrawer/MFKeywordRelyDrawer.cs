using System;
using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFKeywordRelyDrawer: MaterialPropertyDrawer
    {
        private string _relyKeyword;
        private Material _mat;

        public MFKeywordRelyDrawer(string keyword)
        {
            _relyKeyword = keyword;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (_mat != null && _mat.IsKeywordEnabled(_relyKeyword))
            { 
                editor.DefaultShaderProperty(prop, label);
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
    }
}