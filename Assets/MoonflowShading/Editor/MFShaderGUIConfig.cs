using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFShaderGUIConfig:MFSingleton<MFShaderGUIConfig>
    {
        private GUIStyle _moduleTitle;

        public GUIStyle ModuleTitle
        {
            get
            {
                if (_moduleTitle == null || _moduleTitle == GUIStyle.none) InitStyle();
                return _moduleTitle;
            }
        }

        public GUIStyle TotalTitle
        {
            get
            {
                if (TotalTitle == null || TotalTitle == GUIStyle.none) InitStyle();
                return _totalTitle;
            }
        }

        private GUIStyle _totalTitle;
        private Texture2D _logoBanner;
        public MFShaderGUIConfig()
        {
            InitAssets();
            InitStyle();
        }

        private void InitAssets()
        {
            _logoBanner = MFLoadManager.Load<Texture2D>(new MFResInfo("moonflowBanner", ""), true);
        }

        private void InitStyle()
        {
            _moduleTitle = new GUIStyle()
            {
                // border = new RectOffset(5,5,5,5),
                padding = new RectOffset(5,5,0,0),
                margin =  new RectOffset(0,0,20,0),
                fontSize = 14, 
                fontStyle = FontStyle.Bold,
                normal = new GUIStyleState()
                {
                    textColor = Color.white,
                    background = MFLoadManager.Load<Texture2D>(new MFResInfo("moonflowBanner",""), true)
                },
            };
            _totalTitle = new GUIStyle()
            {
                // border = new RectOffset(5,5,5,5),
                padding = new RectOffset(5,5,0,0),
                margin =  new RectOffset(0,0,20,0),
                fontSize = 14, 
                fontStyle = FontStyle.Bold,
                normal = new GUIStyleState()
                {
                    textColor = Color.white,
                    background = Texture2D.blackTexture/*MFLoadManager.Load<Texture2D>(new MFResInfo("moonflowBanner",""), true)*/
                },
            };
        }
    }
}