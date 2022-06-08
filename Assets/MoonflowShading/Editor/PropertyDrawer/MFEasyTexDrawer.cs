using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFEasyTexDrawer: MaterialPropertyDrawer
    {
        private Material _mat;

        public MFEasyTexDrawer()
        {
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            using (new EditorGUILayout.HorizontalScope("box"))
            {
                EditorGUIUtility.labelWidth = 10;
                EditorGUILayout.LabelField(prop.displayName, GUILayout.ExpandWidth(false));
                prop.textureValue = EditorGUILayout.ObjectField((Object)prop.textureValue, typeof(Texture2D), false) as Texture2D;
            }
            // base.OnGUI(position, prop, label, editor);
        }
    }
}