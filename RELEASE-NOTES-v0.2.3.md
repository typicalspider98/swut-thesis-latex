# SWUT Thesis LaTeX v0.2.3

本版本重点完善模板的写作指导、字体检查和公开发行流程。

## 主要更新

- 更正学校英文名称为 **Shandong Vocational and Technical University
  of International Studies**。
- 将“模板快速上手”调整为第一章，并明确该章是使用教程，正式提交
  论文时可以删除。
- 依据学校 Word 模板重写中英文摘要示例：中文摘要约 390 字，英文
  摘要约 242 词，集中说明研究目的、方法、过程、结果和结论的写法。
- 重构正文示例内容，按照绪论、研究设计与实施、研究结果与规范表达、
  讨论与论文组织、总结与展望的逻辑提供写作参考。
- 缺少方正小标宋简体或学校版式使用的中西文字体时，在 PDF 封面显示
  可见提示；补齐字体后提示自动消失。
- 页眉显式使用宋体五号、单倍行距，并按生成 PDF 实测为 10.5 磅。
- 补充 `latexmk` 不可用时的手动编译流程：
  XeLaTeX → Biber → XeLaTeX → XeLaTeX。
- 公开仓库和发行包不再包含学校 Word 原始模板；发行 ZIP 补齐 README
  预览图片和 `.gitignore`。

## 编译方式

模板必须使用 XeLaTeX。推荐将发行版 ZIP 直接导入中国科技云论文协同
编辑服务，并在项目设置中选择 XeLaTeX；也可以在本地使用 MiKTeX 与
TeXstudio。

自动编译：

```powershell
latexmk main.tex
```

手动编译：

```powershell
xelatex main.tex
biber main
xelatex main.tex
xelatex main.tex
```

## 字体说明

公开发行包不附带第三方字体。需要完整复现学校 Word 模板时，请从
合法渠道取得方正小标宋简体，并将字体文件命名为 `FZXBS.ttf` 后放入
项目的 `fonts/` 目录。详细说明见 `fonts/README.md`。

## 下载说明

建议下载 `SWUT-Thesis-LaTeX-v0.2.3.zip`。该文件可以直接导入在线
LaTeX 平台，不需要先解压后逐个上传。
