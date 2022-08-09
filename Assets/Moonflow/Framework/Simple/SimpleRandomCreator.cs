using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Random = UnityEngine.Random;

namespace MoonflowSystem
{
    public class SimpleRandomCreator:EditorWindow
    {
        public static SimpleRandomCreator instance;

        public enum ShapeType
        {
            Quad = 0,
            Circle = 1,
            Box = 2,
            Sphere = 3
        }

        public Transform root;
        public bool randomRotation;
        public GameObject prefab;
        public Queue<GameObject> objList;
        public ShapeType shapeType;
        public float radius;
        public int onceTime;
        
        [MenuItem("Moonflow/Simple/RandowmCreator")]
        public static void ShowWindow()
        {
            if(!instance)instance = GetWindow<SimpleRandomCreator>("随机生成器");
            instance.objList = new Queue<GameObject>();
        }

        private void OnGUI()
        {
            root = EditorGUILayout.ObjectField("父级", root, typeof(Transform)) as Transform;
            prefab = EditorGUILayout.ObjectField("生成对象", prefab, typeof(GameObject)) as GameObject;
            shapeType = (ShapeType)EditorGUILayout.Popup("形状", (int)shapeType, new[] { "方形", "圆形", "盒形", "球形" });
            radius = EditorGUILayout.FloatField("半径", radius);
            onceTime = EditorGUILayout.IntSlider("单次生成数量", onceTime, 1, 100);
            randomRotation = EditorGUILayout.Toggle("随机旋转", randomRotation);
            using (new EditorGUILayout.HorizontalScope("box"))
            {
                if (GUILayout.Button(objList.Count > 0 ? "追加" : "生成"))
                {
                    Create();
                }

                if (GUILayout.Button("清空"))
                {
                    Clear();
                }
            }
            
        }

        private void Create()
        {
            for (int i = 0; i < onceTime; i++)
            {
                Vector3 position = Vector3.zero;
                Quaternion q = Quaternion.identity;
                switch (shapeType)
                {
                    case ShapeType.Quad:
                    {
                        position = new Vector3(Random.Range(-radius, radius), 0, Random.Range(-radius, radius));
                        q = Quaternion.Euler(Random.Range(-1f, 1f), 0, Random.Range(-1f, 1f));
                    }
                        break;
                    case ShapeType.Circle:
                    {
                            position = new Vector3(Random.Range(-1f, 1f), 0, Random.Range(-1f, 1f)).normalized *
                                       Random.Range(0, radius);
                            q = Quaternion.Euler(Random.Range(-1f, 1f), 0, Random.Range(-1f, 1f));
                    }
                    break;
                    case ShapeType.Box:
                    {
                            position = new Vector3(Random.Range(-radius, radius), Random.Range(-radius, radius),
                                Random.Range(-radius, radius));
                            q = Quaternion.Euler(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f));
                    }
                    break;
                    case ShapeType.Sphere:
                    {
                            position = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f))
                                .normalized * Random.Range(0, radius);
                            q = Quaternion.Euler(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f));
                    }
                    break;
                }
                objList.Enqueue(Instantiate(prefab, position, randomRotation ? q : Quaternion.identity, root));
            }
        }

        public void Clear()
        {
            while (objList.Count > 0)
            {
                var obj = objList.Dequeue();
                if (Application.isPlaying)
                {
                    Destroy(obj);
                }
                else
                {
                    DestroyImmediate(obj);
                }
            }
        }
    }
}