# 本地字体目录

本目录用于放置使用者从官方渠道合法取得的字体文件。`.gitignore`
会排除本目录中的 TTF 和 OTF 文件，防止本地字体被误提交到公开仓库。

## 官方获取渠道

- [方正公文写作个人（家庭）版](https://shop.foundertype.com/index.php/AuthOffice/index.html)：
  包含方正小标宋简体、仿宋_GB2312 和楷体_GB2312。
- [方正小标宋](https://www.foundertype.com/index.php/FontInfo/index/id/164)：
  方正小标宋官方产品与授权页面。

## 文件放置

取得字体后，将相应文件放入本目录，并使用以下文件名：

```text
fonts/
├─ FZXBS.ttf
├─ FangSongGB2312.ttf
└─ KaiTiGB2312.ttf
```

其中 `FZXBS.ttf` 对应方正小标宋简体，用于封面固定标题“毕业设计
（论文）”；后两个文件分别对应仿宋_GB2312 和楷体_GB2312。正文宋体、
标题黑体以及西文 Times New Roman、Arial 通常由操作系统提供。

模板缺少这些文件时仍可使用系统字体或 TeX Live 自带字体完成编译。
若 `FZXBS.ttf` 缺失，封面标题下方会显示红色回退提示；补齐字体后
重新编译，提示会自动消失。
如需在 Overleaf 或中国科技云平台复现本地字体效果，可将依法取得的
字体上传到自己的私人项目 `fonts/` 目录。
