using System.Linq;
using Moonflow;
using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFRampDrawer: MaterialPropertyDrawer
    {
        private Material _mat;
        private string[] _keywords;

        public MFRampDrawer(params string[] combinedtuples)
        {
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (!_keywords.Any(t => _mat.IsKeywordEnabled(t))) return;
            editor.TexturePropertySingleLine(label, prop);
            if (GUILayout.Button("Make"))
            {
                MFRampMaker.ShowWindow(_mat, prop.name);
            }
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0f;
        }
    }
}