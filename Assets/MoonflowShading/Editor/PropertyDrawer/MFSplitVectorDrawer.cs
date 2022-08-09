using System;
using Moonflow.Core;
using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFSplitVectorDrawer : MaterialPropertyDrawer
    {
        public struct RangeTuple
        {
            public bool enable;
            public float min;
            public float max;
        }
        private ValueTuple<string, int, RangeTuple>[] _splitName; 
        private string[] _propertyName;
        private Material _mat;
        private MaterialProperty _st;
        private bool _hasInit = false;

        public MFSplitVectorDrawer(string keyword, string splitName)
        {
            _propertyName = keyword.Split(" ");
            SplitName(splitName);
        }
        public MFSplitVectorDrawer(string splitName)
        {
            SplitName(splitName);
        }
        
        public void SplitName(string splitName)
        {
            string[] split = splitName.Split(" ");
            _splitName = new ValueTuple<string, int, RangeTuple>[split.Length];
            for (int i = 0; i < _splitName.Length; i++)
            {
                string[] pair = split[i].Split("#");
                _splitName[i].Item1 = pair[0];
                _splitName[i].Item2 = Convert.ToInt32(pair[1]);
                if (pair.Length > 2)
                {
                    string[] splitRange = pair[2].Split("_");
                    if (splitRange.Length < 2)
                    {
                        MFDebug.LogError("MFSplitVector Range格式错误");
                    }

                    _splitName[i].Item3 = new RangeTuple()
                    {
                        enable = true,
                        min = Convert.ToSingle(splitRange[0]),
                        max = Convert.ToSingle(splitRange[1]),
                    };
                }
                else
                {
                    _splitName[i].Item3 = new RangeTuple()
                    {
                        enable = false,
                        min = 0,
                        max = 1
                    };
                }
            }
        }
        
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _mat = editor.target as Material;
            if (_mat == null) return;
            bool needDraw = false;
            foreach (var t in _propertyName)
            {
                if (_mat.GetFloat(t) == 1f) needDraw = true;
            }
            if (!needDraw) return;
            EditorGUI.BeginChangeCheck();
            
            int offset = 0;

            float oldwidth = EditorGUIUtility.labelWidth;
            float[] data = { prop.vectorValue.x, prop.vectorValue.y, prop.vectorValue.z, prop.vectorValue.w };
            for (int i = 0; i < _splitName.Length; i++)
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    switch (_splitName[i].Item2)
                    {
                        case 1:
                        {
                            if (offset > 3)
                            {
                                MFDebug.LogError("shader面板Vector分离数据超限");
                                return;
                            }
                    
                            if (_splitName[i].Item3.enable)
                            {
                                EditorGUIUtility.labelWidth = 100;
                                EditorGUILayout.LabelField(_splitName[i].Item1);
                                data[offset] = EditorGUILayout.Slider( data[offset], _splitName[i].Item3.min, _splitName[i].Item3.max);
                                EditorGUIUtility.labelWidth = oldwidth;
                            }
                            else
                            {
                                data[offset] = EditorGUILayout.FloatField(_splitName[i].Item1, data[offset]);
                            }
                            offset += 1;
                            break;
                        }
                        case 2:
                        {
                            if (offset > 2)
                            {
                                MFDebug.LogError("shader面板Vector分离数据超限");
                                return;
                            }
                            Vector2 tempData = new Vector2(data[offset], data[offset + 1]);
                            EditorGUIUtility.wideMode = true;
                            float olw = EditorGUIUtility.labelWidth;
                            EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.3f;
                            tempData = EditorGUILayout.Vector2Field(_splitName[i].Item1, tempData);
                            EditorGUIUtility.labelWidth = olw;
                            if (_splitName[i].Item3.enable)
                            {
                                data[offset] = Mathf.Clamp(tempData.x, _splitName[i].Item3.min, _splitName[i].Item3.max);
                                data[offset + 1] = Mathf.Clamp(tempData.y, _splitName[i].Item3.min, _splitName[i].Item3.max);
                            }
                            else
                            {
                                data[offset] = tempData.x;
                                data[offset + 1] = tempData.y;
                            }
                            offset += 2;
                            break;
                        }
                        case 3:
                        {
                            if (offset > 1)
                            {
                                MFDebug.LogError("shader面板Vector分离数据超限");
                                return;
                            }
                            Vector3 tempData = new Vector3(data[offset], data[offset + 1], data[offset + 2]);
                            EditorGUIUtility.wideMode = true;
                            float olw = EditorGUIUtility.labelWidth;
                            EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.3f;
                            tempData = EditorGUILayout.Vector3Field(_splitName[i].Item1, tempData);
                            EditorGUIUtility.labelWidth = olw;
                            if (_splitName[i].Item3.enable)
                            {
                                data[offset] = Mathf.Clamp(tempData.x, _splitName[i].Item3.min, _splitName[i].Item3.max);
                                data[offset + 1] = Mathf.Clamp(tempData.y, _splitName[i].Item3.min, _splitName[i].Item3.max);
                                data[offset + 2] = Mathf.Clamp(tempData.z, _splitName[i].Item3.min, _splitName[i].Item3.max);
                            }
                            else
                            {
                                data[offset] = tempData.x;
                                data[offset + 1] = tempData.y;
                                data[offset + 2] = tempData.z;
                            }
                    
                            offset += 3;
                            break;
                        }
                        default:
                        {
                            MFDebug.LogError("shader面板Vector分离数据长度不对");
                            return;
                        }
                    }
                }
            }
            if(EditorGUI.EndChangeCheck())
                prop.vectorValue = new Vector4(data[0], data[1], data[2], data[3]);
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 0f;
        }
    }
}