using UnityEditor;
using UnityEngine;

namespace MoonflowShading.Editor
{
    [CustomPropertyDrawer(typeof(MFHeaderAttribute))]
    public class MFHeaderDecorator:DecoratorDrawer
    {
        private MFHeaderAttribute _attribute = new MFHeaderAttribute();
        public override void OnGUI(Rect position)
        {
            _attribute = (MFHeaderAttribute) attribute;
            // base.OnGUI(position);
            EditorGUI.LabelField(position, "▣ "+ _attribute.name, MFShaderGUIConfig.GetInstance().ModuleTitle);
        }
    }
}