# Tutorial

Typst 中文教程


[![下载最新版本](https://custom-icon-badges.demolab.com/badge/-Download-blue?style=for-the-badge&logo=download&logoColor=white "下载最新版本")](https://nightly.link/typst-doc-cn/tutorial/workflows/build/main/ebook.zip)  **(latest版本)**

[![下载最新版本](https://custom-icon-badges.demolab.com/badge/-Download-blue?style=for-the-badge&logo=download&logoColor=white "下载最新版本")](https://github.com/typst-doc-cn/tutorial/releases/download/v0.1.0/Typst.Tutorial.CN.v0.1.0.pdf) **(0.1.0版本)**
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

## 复现 Artifacts

生成`typst-docs-v0.11.0.json`：

```bash
cargo install --git https://github.com/typst/typst --locked typst-docs --features="cli" --tag v0.11.0
typst-docs --out-file ./assets/artifacts/typst-docs-v0.11.0.json --assets-dir target/typst-docs/assets
```
