using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

namespace Moonflow
{
    public class MFRampMaker: EditorWindow
    {
        public static MFRampMaker Ins;
        public bool isShow = false;
        public bool AutoLinkMode = false;
        public Material targetMaterial;
        private List<string> texNames;
        private int targetPropertySerial;
        public string propertyName;
        private Gradient _top;
        private Gradient _bottom;
        private int _level;
        private int _size;
        private RenderTexture _rt;
        // private CommandBuffer _cmd;
        private Material _previewMat;
        private Color[] _tempColor;
        private float[] _tempPoint;
        private Texture2D _previewTex;
        private bool _isLinked = false;
        private static readonly int TOP_COLOR_ARRAY = Shader.PropertyToID("_TopColorArray");
        private static readonly int TOP_POINT_ARRAY = Shader.PropertyToID("_TopPointArray");
        private static readonly int BOTTOM_COLOR_ARRAY = Shader.PropertyToID("_BottomColorArray");
        private static readonly int BOTTOM_POINT_ARRAY = Shader.PropertyToID("_BottomPointArray");
        private static readonly int TARGET_RAMP = Shader.PropertyToID("_TargetRamp");

        [MenuItem("Moonflow/Tools/Art/MFRampMaker")]
        public static void ShowWindow()
        {
            Ins = GetWindow<MFRampMaker>();
            Ins.minSize = new Vector2(200, 200);
            Ins.maxSize = new Vector2(400, 300);
            Ins.InitData();
            Ins.Show();
        }
        [MenuItem("CONTEXT/Material/LinkToRampMaker", priority = 100)]
        public static void ShowWindow(MenuCommand menuCommand)
        {
            if (Ins == null)
            {
                Ins = GetWindow<MFRampMaker>();
                Ins.InitData();
                Ins.Show();
            }
            Ins.targetMaterial = menuCommand.context as Material;
            Ins.UpdateProperty();
        }
        
        public static void ShowWindow(Material mat, string propertyName)
        {
            if (Ins == null)
            {
                Ins = GetWindow<MFRampMaker>();
                Ins.InitData();
                Ins.Show();
            }
            Ins.targetMaterial = mat;
            Ins.AutoLinkMode = true;
            Ins.propertyName = propertyName;
            Ins._isLinked = true;
            Ins.UpdateProperty();
        }
        

        private void OnGUI()
        {
            EditorGUI.BeginChangeCheck();
            
            using (new EditorGUILayout.HorizontalScope())
            {
                using (new EditorGUILayout.VerticalScope())
                {
                    using (new EditorGUILayout.VerticalScope("box"))
                    {
                        EditorGUIUtility.labelWidth = 50;
                        EditorGUIUtility.fieldWidth = 50;
                        EditorGUILayout.PrefixLabel("参数");
                        _top = EditorGUILayout.GradientField("上限", _top);
                        _bottom = EditorGUILayout.GradientField("下限", _bottom);
                        if (GUILayout.Button("保存"))
                        {
                            string path = EditorUtility.SaveFilePanel("保存到", Application.dataPath, "RampTex", "TGA");
                            Save(path);
                        }
                    }
                    using (new EditorGUILayout.VerticalScope("box"))
                    {
                        if (targetMaterial != null)
                        {
                            EditorGUILayout.ObjectField(targetMaterial, typeof(Material));
                            if (!AutoLinkMode)
                            {
                                targetPropertySerial = EditorGUILayout.Popup("目标属性", targetPropertySerial, texNames.ToArray());
                                propertyName = texNames[targetPropertySerial];
                            }
                            else
                            {
                                EditorGUILayout.LabelField("目标属性", propertyName);
                            }
                            if (GUILayout.Button(_isLinked ? "断开链接" : "链接"))
                            {
                                _isLinked = !_isLinked;
                            }
                        }
                    }
                    
                }
                using (new EditorGUILayout.VerticalScope("box"))
                {
                    EditorGUILayout.PrefixLabel("贴图预览设置");
                    _level = EditorGUILayout.IntSlider("贴图分辨率级别", _level, 0, 4);
                    EditorGUILayout.LabelField("当前分辨率", Mathf.Pow(2, 5+_level).ToString(CultureInfo.CurrentCulture));

                    if (_rt!=null && _rt.IsCreated())
                    {
                        // _previewTex = AssetPreview.GetAssetPreview(_rt);
                        Rect rect = EditorGUILayout.GetControlRect(true, 200);
                        rect.width = 200;
                        EditorGUI.DrawPreviewTexture(rect, _rt);
                    }
                }
            }
            
            
            if (EditorGUI.EndChangeCheck())
            {
                if (_size != (int)Mathf.Pow(2, 5 + _level))
                {
                    ReNewRT();
                }
                SetGradient();
            }
        }
        
        public void Save(string path)
        {
            RenderTexture.active = _rt;
            _previewTex = new Texture2D(_rt.width, _rt.height, TextureFormat.RGB24, false);
            _previewTex.ReadPixels(new Rect(0, 0, _rt.width, _rt.height), 0, 0);
            RenderTexture.active = null;
            byte[] bytes = _previewTex.EncodeToTGA();
            string[] ts = System.DateTime.Now.ToString().Split(' ', ':', '/');
            string time = string.Concat(ts);
            string filePath = "/TextureFromGradient " + time + ".TGA";
            string fileFullPath = Application.dataPath + filePath;
            string realPath = string.IsNullOrEmpty(path) ? fileFullPath : path;
            File.WriteAllBytes(realPath, bytes);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            if (_isLinked)
            {
                if (realPath.StartsWith(Application.dataPath)) {
                    realPath = "Assets" + realPath.Substring(Application.dataPath.Length);
                }
                Texture2D savedTex = AssetDatabase.LoadAssetAtPath(realPath, typeof(Texture2D)) as Texture2D;
                targetMaterial.SetTexture(propertyName, savedTex);
                _isLinked = false;
            }
        }

        private void OnInspectorUpdate()
        {
            if (_rt != null)
            {
                UpdateRT();
            }

            if (_isLinked)
            {
                targetMaterial.SetTexture(propertyName, _rt);
            }
        }

        private void UpdateProperty()
        {
            if (targetMaterial == null) return;
            targetMaterial.GetTexturePropertyNames(texNames);
        }

        public void InitData()
        {
            isShow = true;
            _top = new Gradient();
            _bottom = new Gradient();
            texNames = new List<string>();
            // _cmd = new CommandBuffer();
            Shader s = Shader.Find("Hidden/Moonflow/RampMaker");
            _previewMat = new Material(s);
            NewRT();
            SetGradient();
        }

        private void ReNewRT()
        {
            ReleaseOldRT();
            NewRT();
        }

        private void ReleaseOldRT()
        {
            if(_rt!=null && _rt.IsCreated()) _rt.Release();
        }

        private void NewRT()
        {
            ReleaseOldRT();
            _size = (int)Mathf.Pow(2, 5 + _level);
            _rt = new RenderTexture(_size, _size, 0, RenderTextureFormat.Default, RenderTextureReadWrite.sRGB);
            _rt.name = "test";
            _rt.enableRandomWrite = true;
            _rt.Create();
        }

        private void UpdateRT()
        {
            if (_rt.IsCreated())
            {
                Graphics.Blit(Texture2D.whiteTexture, _rt, _previewMat);
            }
        }

        private void SetGradient()
        {
            _tempColor = new Color[10];
            _tempPoint = new float[10];
            int count = _top.colorKeys.Length;
            int offset = 0;
            for (int i = 0; i < 10; i++)
            {
                if (i == 0 && _top.colorKeys[0].time !=0)
                {
                    _tempColor[0] = _top.colorKeys[0].color;
                    _tempPoint[0] = 0;
                    offset = -1;
                    continue;
                }
                if (i + offset < count)
                {
                    _tempColor[i] = _top.colorKeys[i + offset].color;
                    _tempPoint[i] = _top.colorKeys[i + offset].time;
                }
                else
                {
                    _tempColor[i] = _top.colorKeys[count-1].color;
                    _tempPoint[i] = 1;
                }
            }
            _previewMat.SetColorArray(TOP_COLOR_ARRAY, _tempColor);
            _previewMat.SetFloatArray(TOP_POINT_ARRAY, _tempPoint);
            
            count = _bottom.colorKeys.Length;
            offset = 0;
            for (int i = 0; i < 10; i++)
            {
                if (i == 0 && _bottom.colorKeys[0].time !=0)
                {
                    _tempColor[0] = _bottom.colorKeys[0].color;
                    _tempPoint[0] = 0;
                    offset = -1;
                    continue;
                }
                if (i + offset < count)
                {
                    _tempColor[i] = _bottom.colorKeys[i + offset].color;
                    _tempPoint[i] = _bottom.colorKeys[i + offset].time;
                }
                else
                {
                    _tempColor[i] = _bottom.colorKeys[count-1].color;
                    _tempPoint[i] = 1;
                }
            }
            _previewMat.SetColorArray(BOTTOM_COLOR_ARRAY, _tempColor);
            _previewMat.SetFloatArray(BOTTOM_POINT_ARRAY, _tempPoint);
        }

        private void OnDisable()
        {
            isShow = false;
            RenderTexture.active = null;
            _rt.Release();
            // _cmd.Release();
            DestroyImmediate(_previewMat);
        }
    }
}