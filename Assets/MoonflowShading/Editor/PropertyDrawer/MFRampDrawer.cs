using Moonflow;
using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFRampDrawer: MaterialPropertyDrawer
    {
        private Material _mat;

        public MFRampDrawer()
        {
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            // using (new EditorGUILayout.HorizontalScope("box"))
            // {
                // float old = EditorGUIUtility.labelWidth;
                // EditorGUIUtility.labelWidth = 10;
                // EditorGUILayout.LabelField(prop.displayName, GUILayout.ExpandWidth(false));
                // prop.textureValue = EditorGUILayout.ObjectField((Object)prop.textureValue, typeof(Texture2D), false) as Texture2D;
                editor.TexturePropertySingleLine(label, prop);
                if (GUILayout.Button("Make"))
                {
                    MFRampMaker.ShowWindow(_mat, prop.name);
                }

                // EditorGUIUtility.labelWidth = old;
            // }
            
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0f;
        }
    }
}