### Moonflow Property Drawer System
* MFEasyTex 
  * __[MFEasyTex]\_Exp("Exp", 2D) = "white"{}__
  * 需要挂在Tex参数上
  * 单行贴图属性，没有ScaleOffset
* MFKeywordExclude(keyword0, keyword1, ...)
  * __[MFKeywordExclude(\_MFTEX\_ON, \_MFTEX\_PRO\_ON)]\_Exp("Exp", 2D) = "white"{}__
  * shader存在输入的任何一个Keyword时，该参数就不显示
* MFKeywordRely(keyword0, keyword1, ...)  
  * __[MFKeywordRely(\_MFTEX\_ON, \_MFTEX\_PRO\_ON)]\_Exp("Exp", 2D) = "white"{}__
  * shader存在输入的任何一个Keyword时，该参数即显示
* MFModuleDefinition(keyword, createMode(Bool)) 
  * __[MFModuleDefinition(\_MFTEX\_ON, True)]\_Exp("Exp", Float) = 0__
  * 需要挂在Float参数上
  * createMode为True时，开关控制第一输入项对应的keyword的开关(作为生成Keyword的选项)
  * createMode为False时，仅作常规0/1判断的Branch开关(作为Keyword分支控制项，只做面板识别作用，不会传递到Shader内)
* MFModuleElement(name)
  * __[MFModuleElement(\_Exp)]\_Exp1("Exp1", Float) = 0__
  * 需要挂载Float参数上
  * 输入的Float参数为1时显示
* MFModuleElement(name, keywordName)
  * __[MFModuleElement(\_Exp, \_MFTEX\_ON)]\_Exp1("Exp1", Float) = 0__
  * 需要挂载Float参数上
  * 输入的第一个Float参数为1，且输入的第二参数keyword打开时显示
* MFModuleHeader(title)
  * 绘制一个文字为输入title的标题
* MFPublicTex(tuple0, tuple1, tuple2)
  * __[MFPublicTex(\_MFCEL\_STOCKING Weave True, \_MFCEL\_FACESDF SDFShadow False)]\_Exp1("Exp1", 2D) = "white"{}__
  * 需要挂载Tex参数上
  * 每组tuple需要三个参数，用空格分隔，依次是keyword、显示名称、显示模式
  * 参数在材质开启任意一个tuple内的keyword参数时显示
  * 如果显示模式为True则为常规显示（带Scale Offset）并以给定的显示名称显示在面板
  * 如果显示模式为False则为单行显示（无Scale Offset）并以给定的显示名称显示在面板
* MFRamp()
  * __[MFRamp]\_Exp1("Exp1", 2D) = "white"{}__
  * 需要挂载Tex参数上
  * 标记该贴图为Ramp贴图，其下方会有一个Make按钮，点击后打开Ramp制作工具并链接至此贴图参数
* MFSplitVectorDrawer(splitParam)
  * __[MFSplitVectorDrawer(SpecMaskOffset#1#0_1 Shift#1 Layer1Offset#1#0.0001_1 Layer2Offset#1#0.0001_1)]
    \_HairData("HairData", Vector) = (1,1,1,1)__
  * 根据输入的splitParam把一个Vector拆分成多个Float参数显示
  * splitParam以空格标记选项
  * 每个选项格式为 显示名称#数据个数 或 显示名称#数据个数#最小值_最大值,如果设置了minmax值且只有一个项则会显示为slider
    * 示例中 Layer1Offset#1#0.0001_1 的解释：
      * 参数名 Layer1Offset
      * 1个float
      * 最小值0.0001
      * 最大值1
* MFSplitVectorDrawer(keywords, splitParam)
  * __[MFSplitVectorDrawer(\_Hair \_Face, SpecMaskOffset#1#0_1 Shift#1 Layer1Offset#1#0.0001_1 Layer2Offset#1#0.0001_1)]
    \_HairData("HairData", Vector) = (1,1,1,1)__
  * splitParam用法同上
  * keywords以空格分界标记若干Keywords，材质开启其中任意一个keywords时显示参数

