using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFPublicTexDrawer : MaterialPropertyDrawer
    {
        private bool simple;
        private ValueTuple<string, string, bool>[] pairs;
        private Material _mat;
        private MaterialProperty _st;
        private GUIStyle _mixingStyle = new GUIStyle()
        {
            fontSize = 12,
            fontStyle = FontStyle.Bold,
            normal = new GUIStyleState()
            {
                textColor = Color.white
            }
        };

        public MFPublicTexDrawer(params string[] combinedtuples)
        {
            simple = false;
            int length = combinedtuples.Length;
            pairs = new (string, string, bool)[length];
            for (int i = 0; i < length; i++)
            {
                string ori = combinedtuples[i];
                string[] oriPair = ori.Split(" ");
                pairs[i].Item1 = oriPair[0];
                pairs[i].Item2 = oriPair[1];
                pairs[i].Item3 = Convert.ToBoolean(oriPair[2]);
            }
        }

        public MFPublicTexDrawer()
        {
            simple = true;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (simple)
            {
                editor.TexturePropertySingleLine(new GUIContent(prop.displayName), prop);
                return;
            }
            for (int i = 0; i < pairs.Length; i++)
            {
                if (_mat.IsKeywordEnabled(pairs[i].Item1))
                {
                    if (pairs[i].Item3)
                    {
                        editor.DefaultShaderProperty(prop, pairs[i].Item2);
                    }
                    else
                    {
                        editor.TexturePropertySingleLine(new GUIContent(pairs[i].Item2), prop);
                    }
                    break;
                }
            }
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0f;
        }
    }
}