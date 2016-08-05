# glist 2.0

[![apm](https://img.shields.io/apm/dm/glist.svg?maxAge=2592000)](https://atom.io/packages/glist)

Taking notes with Github Gist from atom, inspired by [notational velocity](http://notational.net/)

在 atom 中像 [notational velocity](http://notational.net/) 一样快速记笔记，贴代码片段，甚至写博客，迅速保存到 github gist 上

![](http://notational.net/images/notational-diagram.png)

## Rationale
1. gist is version controlled, and support almost all markup and programming language.
2. atom is awesome (at lease for markdown).
3. Notational Velocity is simple, fast and awesome. I use emacs deft every day, but it doesn't have any version control.

**glist** combine all these cool things

## 为什么
1. gist 带版本管理，每个 gist 都是一个 git repo, 而且支持各种标记和编程语言
2. atom 非常好用（虽然我写代码时用 emacs，但是 markdown 支持并不如 org-mode）而且开源，插件容易写，于是花了两天
3. Notational Velocity 的方式记笔记非常高效，这一点在 emacs 中对应的是 deft mode，缺点是 deft mode 只能同步 dropbox，并不能结合有版本管理的服务 如 gist

## Install
```
apm install glist
```

## Configure
![](https://www.evernote.com/l/ABfoXCABoadBmpTgE92e5DtGnt61pgXFfs4B/image.png)
### Github Token
1. get a github auth token via either [curl](https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization) or [gui](https://github.com/blog/1509-personal-api-tokens)
2. copy the token and paste to glist's setting
3. :point_right: **RESTART** your atom

> ⚠ your token will be saved **safely** under `~/.atom/glist/.config.cson`, then token in config panel willbe mask as `********`, then it will be safe to use dotfiles to sync you atom config.

### Gist Directory
you can customize where to store your gist files, by default they are under `HOME/.atom/package/glist/gists`

:heavy_exclamation_mark: the path has to be a absolute, no relative, `~` doesn't work either

### Token Path
this is the place where storing you github token, config it to a safe place. by default it's `~/.atom/glist/.config.cson`

### default suffix for new gist
by default every new gist created is markdown.

## How to Use

### find/open gist
![](https://github.com/jcouyang/glist/raw/master/imgs/Styleguide_-__Users_jcouyang_Develop_glist_-_Atom.png)

![](https://github.com/jcouyang/glist/raw/master/imgs/react-tips_md_-__Users_jcouyang_Develop_glist_-_Atom_2.png)
### edit gist
![](https://github.com/jcouyang/glist/raw/master/imgs/react-tips_md_-__Users_jcouyang_Develop_glist_-_Atom_1.png)

![](https://github.com/jcouyang/glist/raw/master/imgs/react-tips_md_-__Users_jcouyang_Develop_glist_-_Atom.png)
### create gist
![](https://github.com/jcouyang/glist/raw/master/imgs/README_md_-__Users_jcouyang_Develop_glist_-_Atom.png)

![](https://github.com/jcouyang/glist/raw/master/imgs/some-not_exist_gist_md_-__Users_jcouyang__atom_packages_glist_gists_-_Atom.png)

> now create a gist with you own suffix just by adding an `!` at the end. for example `fancy ruby file.rb` will now actually create a ruby file instead of default markdown.

### copy gist url
`ctrl-c cmd-c`

### open gist on web
just press `ctrl-c ctrl-o` while a gist file opened. and the url will also copied into you clipboard

### delete gist file
in the gist file you wanna delete, press `ctrl-c ctrl-d`

### delete gist folder
in any gist file, press `ctrl-c cmd-d` on mac, on windows `cmd` is `windows` key? im not sure

### TODO:
- [X] delete gist file
- [X] delete gist
- [X] open gist on web
- [X] copy gist URL
- [X] writing tests

now I can use Atom and gist in place of Notational Velocity/Evernote

[Thank you! Let me buy you a :beer: please~](https://gum.co/3q)
