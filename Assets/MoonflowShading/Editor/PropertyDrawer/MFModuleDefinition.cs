using System;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFModuleDefinition: MaterialPropertyDrawer
    {
        private string _relyKeyword;
        private Material _mat;
        private bool _toggle;
        private bool _enabled;
        private bool _createMode;

        public MFModuleDefinition(string keyword, string create)
        {
            _relyKeyword = keyword;
            _createMode = Convert.ToBoolean(create);
        }
        public MFModuleDefinition()
        {
            _relyKeyword = "";
        }
 
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            
            _mat = editor.target as Material;
            if (_mat != null)
            {
                if (_createMode)
                {
                    _enabled = true;
                    EditorGUI.BeginChangeCheck();
                    EditorGUI.showMixedValue = prop.hasMixedValue;
                    _toggle = prop.floatValue == 1f;
                    _toggle = EditorGUI.ToggleLeft(MFShaderGUIUtility.GetRect(prop), prop.displayName, _toggle, MFShaderGUIConfig.GetInstance().ModuleTitle);
                    EditorGUI.showMixedValue = false;
                    if (EditorGUI.EndChangeCheck())
                    {
                        prop.floatValue = _toggle ? 1f : 0f;
                        if (_toggle)
                        {
                            _mat.EnableKeyword(_relyKeyword);
                        }
                        else
                        {
                            _mat.DisableKeyword(_relyKeyword);
                        }
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(_relyKeyword))
                    {
                        _enabled = _mat.IsKeywordEnabled(_relyKeyword);
                        _mat.SetFloat(prop.name, _enabled ? 1 : 0);
                        if (_enabled)
                        {
                            EditorGUI.LabelField(MFShaderGUIUtility.GetRect(prop), "▣ "+prop.displayName, MFShaderGUIConfig.GetInstance().ModuleTitle);
                        }
                    }
                }
                
               
                
            }
        }
        
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0;
        }
        
    }
}