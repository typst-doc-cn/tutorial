# tutorial

Typst 中文教程

## 安装字体

```bash
git submodule update --init --recursive
```

## 编译电子书

```bash
typst compile --root . --font-path ./assets/typst-fonts/ --font-path ./assets/fonts/ ./src/ebook.typ
```

## 编译单独章节

选择一个章节文件，比如 `第一章.typ`，然后执行：

```bash
typst compile --root . --font-path ./assets/typst-fonts/ --font-path ./assets/fonts/ 章节文件.typ
```
