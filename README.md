<div align="center">

# 山东外国语职业技术大学本科毕业设计（论文）LaTeX 模板

**面向全校本科生的中文毕业设计（论文）排版模板**

[![Version](https://img.shields.io/badge/version-v0.2.1-1677ff?style=flat-square)](https://gitee.com/typicalspider/swut-thesis-latex/releases)
[![Engine](https://img.shields.io/badge/engine-XeLaTeX-008080?style=flat-square)](#编译器要求)
[![Online](https://img.shields.io/badge/online-Overleaf%20%7C%20CSTCloud-2e7d32?style=flat-square)](#快速开始推荐在线使用)
[![Code License](https://img.shields.io/badge/code%20license-MIT-f5a623?style=flat-square)](LICENSE)

[完整示例 PDF](main.pdf) ·
[Gitee 发行版](https://gitee.com/typicalspider/swut-thesis-latex/releases) ·
[GitHub Releases](https://github.com/typicalspider98/swut-thesis-latex/releases)

</div>

本项目以学校发布的
`SWUT-2026届毕业设计（论文）格式模板网站公布版.docx`
为排版规范来源，面向中文本科毕业设计（论文）。模板统一处理封面、
声明、摘要、目录、正文、图表、参考文献、致谢和附录等版式，使用者
主要填写论文信息与内容，无需逐项手工调整字体、字号和行距。

## 模板预览

<table>
  <tr>
    <td align="center" width="25%">
      <a href="docs/images/readme/preview-cover.png">
        <img src="docs/images/readme/preview-cover.png" alt="论文封面预览">
      </a>
      <br><sub>论文封面</sub>
    </td>
    <td align="center" width="25%">
      <a href="docs/images/readme/preview-declaration.png">
        <img src="docs/images/readme/preview-declaration.png" alt="诚信承诺书与版权使用授权声明预览">
      </a>
      <br><sub>承诺书与授权声明</sub>
    </td>
    <td align="center" width="25%">
      <a href="docs/images/readme/preview-contents.png">
        <img src="docs/images/readme/preview-contents.png" alt="论文目录预览">
      </a>
      <br><sub>自动生成的目录</sub>
    </td>
    <td align="center" width="25%">
      <a href="docs/images/readme/preview-figures.png">
        <img src="docs/images/readme/preview-figures.png" alt="图片、表格和正文排版预览">
      </a>
      <br><sub>图片、表格与正文</sub>
    </td>
  </tr>
</table>

<p align="center">
  点击缩略图可查看原图，完整排版效果请查看
  <a href="main.pdf"><strong>main.pdf</strong></a>。
</p>

## 编译器要求

**本模板必须使用 XeLaTeX 编译，不能使用 pdfLaTeX。** 模板依赖
XeLaTeX 对 UTF-8 中文、系统字体及 OpenType/TrueType 字体的支持；
使用 pdfLaTeX 会直接停止编译。项目中的 `latexmkrc` 已设置为调用
XeLaTeX 和 Biber，在本地运行 `latexmk main.tex` 即可。

## 快速开始（推荐在线使用）

无需在电脑上安装 LaTeX 环境。请先从
[Gitee 发行版页面](https://gitee.com/typicalspider/swut-thesis-latex/releases)
或
[GitHub Releases](https://github.com/typicalspider98/swut-thesis-latex/releases)
下载最新版本的 ZIP 压缩包，然后将 ZIP 直接导入在线 LaTeX 平台。
不要先解压后逐个上传文件，否则容易遗漏目录或资源文件。

### 使用 Overleaf

1. 登录 [Overleaf](https://www.overleaf.com/)，在项目页面依次选择
   **New Project → Upload Project**。
2. 选择下载的模板 ZIP 压缩包并等待导入完成。
3. 进入项目后，打开左上角的 **Menu**，在 **Compiler** 中选择
   **XeLaTeX**，不能使用默认的 pdfLaTeX。
4. 确认主文档为 `main.tex`，然后点击 **Recompile** 完成编译。

### 使用中国科技云论文协同编辑服务

登录[中国科技云论文协同编辑服务](https://latex.cstcloud.cn/)后，按照
与 Overleaf 相同的方式上传模板 ZIP。导入后同样需要打开左上角的
**Menu**，将 **Compiler** 设置为 **XeLaTeX**，主文档设置为
`main.tex`。该服务可使用微信扫码登录，服务介绍见
[中国科技云资源页面](https://www1.cstcloud.cn/resources/452)。

两个平台的默认编译器都可能是 pdfLaTeX。首次导入后必须先检查
**Menu → Compiler**，确认已经选择 **XeLaTeX**，再开始编译。

导入并编译成功后：

1. 修改 `main.tex` 第 2 区的论文题目、作者、学院、专业等信息。
   `\thesistitle` 保存用于页眉、书签等位置的完整题目；封面需要指定
   换行时，使用 `\coverthesistitle{第一行\\第二行}`；可选的第三行
   使用 `\thesissubtitle{副标题}`，没有副标题时删除或注释该命令。
   诚信承诺书和版权使用授权声明的日期分别使用
   `\commitmentdate{年}{月}{日}` 与
   `\authorizationdate{年}{月}{日}` 填写；需要打印后手写时将三个
   参数留空即可。
   示例 PDF 中已直接标注“主标题示例”和“副标题示例”，便于辨认。
2. 在 `chapters/` 中撰写正文，在 `references.bib` 中维护参考文献。
   第二章“模板快速上手”说明了新建章节、正文分段、插图、引用和
   编译的推荐写法。

## 使用界面

下图分别展示在线平台与本地编辑器中的典型工作界面。图片可点击放大；
两种方式生成的论文版式一致，选择适合自己的写作环境即可。

<table>
  <tr>
    <th width="50%">Overleaf 在线编译</th>
    <th width="50%">TeXstudio 本地编译</th>
  </tr>
  <tr>
    <td>
      <a href="docs/images/readme/overleaf-workspace.png">
        <img src="docs/images/readme/overleaf-workspace.png" alt="Overleaf 在线编辑与 PDF 预览界面">
      </a>
    </td>
    <td>
      <a href="docs/images/readme/texstudio-workspace.png">
        <img src="docs/images/readme/texstudio-workspace.png" alt="TeXstudio 本地编辑、编译与 PDF 预览界面">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center"><sub>上传发行版 ZIP，选择 XeLaTeX 后即可编译</sub></td>
    <td align="center"><sub>配合 MiKTeX 完成本地编辑、编译和 PDF 预览</sub></td>
  </tr>
</table>

## 本地编译（可选）

在 Windows 系统中，建议配合 MiKTeX 与 TeXstudio 使用：

- [MiKTeX](https://miktex.org/download) 是 TeX 发行版，提供 XeLaTeX、
  Biber、宏包管理器以及生成 PDF 所需的基础组件。Windows 用户可下载
  **Basic Installer** 完成安装。
- [TeXstudio](https://www.texstudio.org/) 是集成式 LaTeX 编辑器，提供
  语法高亮、命令补全、错误定位、内置 PDF 查看器以及源代码与 PDF
  双向定位等功能。

MiKTeX 负责提供编译器和宏包，TeXstudio 负责编辑源文件并调用编译
工具。TeXstudio 本身不包含完整的 TeX 编译环境，因此应先安装
MiKTeX，再安装 TeXstudio。

完成安装后，建议进行以下配置：

1. 打开 MiKTeX Console，检查并安装可用更新。
2. 在 MiKTeX Console 中启用缺失宏包的自动安装功能。首次编译本模板
   时，MiKTeX 将按需安装 `ctex`、`biblatex` 和
   `biblatex-gb7714-2015` 等宏包。
3. 打开 TeXstudio 的构建设置，将默认编译器设为 **XeLaTeX**，将默认
   参考文献工具设为 **Biber**。
4. 使用 TeXstudio 打开项目根目录中的 `main.tex`，然后执行构建。

也可以在项目根目录通过命令行完成编译：

```powershell
latexmk main.tex
```

如需手动编译，可依次运行：

```powershell
xelatex main.tex
biber main
xelatex main.tex
xelatex main.tex
```

生成文件为 `main.pdf`。

## 字体获取与本地使用

公开发行包不直接附带第三方字体文件。需要完整复现学校 Word 模板时，
请从字体厂商官方渠道取得字体，并将文件放入项目的 `fonts/` 目录。

- [方正公文写作个人（家庭）版](https://shop.foundertype.com/index.php/AuthOffice/index.html)
  包含方正小标宋简体、黑体、仿宋_GB2312 和楷体_GB2312，适用于个人
  非商业的文档编辑、显示和打印。
- [方正小标宋官方字体页面](https://www.foundertype.com/index.php/FontInfo/index/id/164)
  提供字体介绍、个人非商业授权说明和官方获取入口。
- [方正粗黑宋官方字体页面](https://www.foundertype.com/index.php/FontInfo/index/id/195)
  提供方正粗黑宋简体的授权与官方获取入口。

取得字体后，按照 [`fonts/README.md`](fonts/README.md) 中的文件名放置。
本地编译时模板会自动读取排版所需的本地字体。Overleaf 或中国科技云
平台用户可将依法取得的字体上传到自己的私人项目 `fonts/` 目录；
不要将字体文件提交到公开仓库或可公开访问的在线项目。

Windows 自带的仿宋和楷体信息可参阅 Microsoft 官方的
[FangSong](https://learn.microsoft.com/en-ie/typography/font-list/fangsong)
和 [KaiTi](https://learn.microsoft.com/en-us/typography/font-list/kaiti)
页面。系统字体与旧版 `_GB2312` 文件并非同一个字体文件，模板会根据
实际可用字体自动选择或回退。

## 已实现的版式与功能

- 中文正文优先使用宋体，标题优先使用黑体。
- 西文和数字优先使用 Times New Roman，图表题中的西文优先使用 Arial。
- 封面校徽和手写校名使用从 Word 原组合对象直接导出的单张图片，
  按 Word 中的 397.95 pt × 83.45 pt 原尺寸放置，不使用文字重排校名。
- 诚信承诺书和版权使用授权声明按照 Word 原模板合排在同一页，
  两组正文、签名栏和日期栏均保留。
- 中英文摘要均强制设置 2 字符首行缩进和精确 1.5 倍行距；中英文
  关键词命令会检查关键词数量是否处于 3～5 个范围。
- 目录条目使用宋体小四号、18 磅行距，显示到三级标题；章、节和小节
  条目均使用密集点线连接页码。
- 正文为宋体小四号、约 23.4 磅基线距、首行缩进 24 磅；一级、二级和三级
  标题分别使用黑体小三、黑体四号和黑体小四号。各级标题编号与
  标题文字之间统一使用约 3 磅的普通空格。
- 图、表和代码块在放不下时会整体转入下一页，并自动阻止后续段落
  越过它们提前排版，保证最终 PDF 与源文件的阅读顺序一致。
- 致谢标题中保留两个汉字宽度的间隔，致谢正文与普通正文采用相同的
  字体、行距和首行缩进；附录标题沿用一级标题格式。
- 示例工程已扩展为六章，其中第二章提供当前模板的快速上手说明，
  并包含学术写作、图表、公式、脚注、程序代码、结构化标题、
  参考文献、致谢和附录等完整内容。
- “毕业设计（论文）”在本地提供相应字体时使用 Word 原模板指定的
  方正小标宋简体 36 磅，否则自动使用黑体回退字体。
- 如果目标机器缺少 Windows 字体，模板会回退到 TeX Live 自带的
  Fandol 和 TeX Gyre 字体，保证可以编译；正式提交前仍应在学校指定
  字体环境中核对版式。
- 公开仓库暂不附带第三方字体文件；确认再分发授权后方可加入发布包。
  字体可从上述官方渠道取得，并按照 `fonts/README.md` 放入本地项目。

## 使用提示

- `main.tex`、`chapters/` 和 `references.bib` 是日常写作的主要编辑位置；
  `swutthesis.cls` 用于统一控制版式，通常不需要修改。
- 示例中的题目、摘要、正文、参考文献、致谢和附录均应替换为实际内容。
- 图、表、公式、代码块和参考文献均使用模板已有的示例结构；不手工
  设置字号、行距、页码、目录点线或编号。
- 正式提交前，建议在学校指定的字体环境中重新编译并核对最终 PDF。

## 目录结构

```text
.
├─ assets/                  校徽等资源
├─ chapters/                正文章节
├─ fonts/                   可选字体的放置说明（公开仓库不附字体文件）
├─ swutthesis.cls           模板类文件
├─ main.tex                 完整示例
├─ references.bib           参考文献数据库
├─ latexmkrc                自动化编译配置
└─ FORMAT-SPEC-v0.2.0.md    从 Word 模板提取的格式基线
```

## 版本记录

- **v0.2.1（2026-07-27）**：补充诚信承诺书和版权使用授权声明的日期
  命令，支持直接填写或留空手写；隐藏声明页签名提示文字，微调封面
  信息栏线条，并补充方正字体的官方获取与本地放置说明；增加 GitHub
  Release 下载入口。
- **v0.2.0（2026-07-24）**：完善封面、声明、摘要、目录、图表、公式、
  参考文献、致谢和附录；补充模板快速上手章节，统一代码块排版和分页
  行为；明确 XeLaTeX 编译要求和在线平台使用方式，清理已知的 xeCJK
  字体重定义警告，并更新公开格式基线说明；提供可直接导入 Overleaf
  和中国科技云论文协同编辑服务的 ZIP 发行包。
- **v0.1**：完成项目框架和 Word 模板主要版式规则的初步实现。

本项目从 v0.2.0 起遵循
[语义化版本 2.0.0](https://semver.org/lang/zh-CN/)；主版本号为 0
表示模板仍处于持续完善阶段。
