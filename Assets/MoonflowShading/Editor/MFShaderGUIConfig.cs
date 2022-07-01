using UnityEngine;

namespace MoonflowShading.Editor
{
    public class MFShaderGUIConfig:MFSingleton<MFShaderGUIConfig>
    {
        public GUIStyle ShaderTitle;
        public GUIStyle ModuleTitle;
        private Texture2D _logoBanner;
        private Texture2D _logoBannerWhite;
        public MFShaderGUIConfig()
        {
            InitAssets();
            InitStyle();
        }

        private void InitAssets()
        {
            _logoBanner = MFLoadManager.Load<Texture2D>(new MFResInfo("moonflowBanner", ""), true);
            _logoBannerWhite = MFLoadManager.Load<Texture2D>(new MFResInfo("moonflowBannerWhite", ""), true);
        }

        private void InitStyle()
        {
            ModuleTitle = new GUIStyle()
            {
                // border = new RectOffset(5,5,5,5),
                padding = new RectOffset(5,5,0,0),
                margin =  new RectOffset(0,0,20,0),
                fontSize = 14, 
                fontStyle = FontStyle.Bold,
                normal = new GUIStyleState()
                {
                    textColor = Color.white,
                    background = _logoBanner
                },
            };
            ShaderTitle = new GUIStyle()
            {
                // border = new RectOffset(5,5,5,5),
                padding = new RectOffset(5,5,0,0),
                margin =  new RectOffset(0,0,20,0),
                fontSize = 14, 
                fontStyle = FontStyle.Bold,
                normal = new GUIStyleState()
                {
                    textColor = Color.black,
                    background = _logoBannerWhite
                },
            };
        }
    }
}