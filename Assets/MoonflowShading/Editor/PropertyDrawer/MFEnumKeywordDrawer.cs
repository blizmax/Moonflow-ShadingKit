using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFEnumKeywordDrawer: MaterialPropertyDrawer
    {
        private string _relyKeyword;
        private string[] _subKeyword;
        private string _prefix;
        private Material _mat;
        
        public MFEnumKeywordDrawer(string relyKeyword, string keyword)
        {
            _relyKeyword = relyKeyword;
            _subKeyword = keyword.Split(" ");
            
        }

        public MFEnumKeywordDrawer(string keyword)
        {
            _subKeyword = keyword.Split(" ");
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (_mat != null)
            {
                if (string.IsNullOrEmpty(_relyKeyword))
                {
                    Draw(prop);
                }
                else
                {
                    for (int i = 0; i < _relyKeyword.Length; i++)
                    {
                        if (_mat.IsKeywordEnabled(_relyKeyword))
                        {
                            Draw(prop);
                            break;
                        }
                    }
                }
            }
        }

        private void Draw(MaterialProperty prop)
        {
            _prefix = prop.name.ToUpper() + "_";
            prop.floatValue = (float)EditorGUILayout.Popup(prop.displayName, (int)prop.floatValue, _subKeyword);
            for (int i = 0; i < _subKeyword.Length; i++)
            {
                string keyword = _prefix + _subKeyword[i].ToUpper();
                if (i == (int)prop.floatValue)
                {
                    _mat.EnableKeyword(keyword);
                }
                else
                {
                    _mat.DisableKeyword(keyword);
                }
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
    }
}