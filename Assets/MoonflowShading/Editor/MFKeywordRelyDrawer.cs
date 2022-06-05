using System;
using System.Linq;
using Moonflow.Core;
using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFKeywordRelyDrawer: MaterialPropertyDrawer
    {
        private string _relyKeyword;
        private MaterialProperty _relyProp;
        private Material _mat;

        public MFKeywordRelyDrawer(string keyword)
        {
            _relyKeyword = keyword;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (Array.IndexOf(_mat.shaderKeywords, _relyKeyword) != -1)
            { 
                editor.DefaultShaderProperty(prop, label);
            }
        }
    }
}