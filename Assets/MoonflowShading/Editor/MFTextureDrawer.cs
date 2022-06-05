using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFTextureDrawer: MaterialPropertyDrawer
    {
        private bool _withST;

        public MFTextureDrawer(bool hasTileOffset = false)
        {
            _withST = hasTileOffset;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (!_withST)
            {
                using (new EditorGUILayout.HorizontalScope("box"))
                {
                    // EditorGUI
                }
            }
            // base.OnGUI(position, prop, label, editor);
        }
    }
}