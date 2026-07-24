# XeLaTeX + Biber 自动化编译配置。
# 在项目根目录运行 `latexmk main.tex` 即可完成所需的多轮编译。
$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$bibtex = 'biber %O %B';
$pdf_mode = 5;
# 目录、交叉引用或参考文献发生变化时允许自动重复编译。
$max_repeat = 5;
