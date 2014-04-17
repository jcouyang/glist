# glist

![A screenshot of your spankin' package](https://raw.github.com/jcouyang/glist/master/media/glist.gif)

glist let you list and edit gist within atom.

Install
=======
```
apm install glist
```
1.0.0 is a major change, It use git submodule to manage your gist, so

:heavy_exclamation_mark: you may need to do [Permanently authenticating with Git repositories](https://confluence.atlassian.com/display/STASH/Permanently+authenticating+with+Git+repositories)
first

Setting
========

open glist's setting and input username and user token if they are empty.

by default, glist will read them from your git config.

How to Use
==========
there is kind of `glist mode` concept if you've use the emacs gist mode before, you can `ctrl-x ctrl-g` to toggle on/off `glist mode`

1. just toggle on `glist` you'll redirected to your gists folder, and update all your gists into the folder.

2. `cmd-t` to find any gist you wanna edit

3. `ctrl-x ctrl-s` will both save your gist locally and update on gist.github.com

4. you can aslo delete a gist with command "glist:delete"

now I can use Atom and gist in place of evernote :beer:
