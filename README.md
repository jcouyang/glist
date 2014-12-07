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

1. open glist's setting and input username
2. `ctrl-c ctrl-g` toggle glist on
3. **first time** it will ask for your gist token, here is how you can get one via [curl](https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization) or [gui](https://github.com/blog/1509-personal-api-tokens)



How to Use
==========
there is kind of `glist mode` concept if you've use the emacs gist mode before, you can `ctrl-c ctrl-g` to toggle on/off `glist mode`

1. just toggle on `glist` you'll redirected to your gists folder, and update all your gists into the folder(using git submodule).

2. `cmd-t` to find any gist you wanna edit

3. `ctrl-x ctrl-s` will both save your gist locally and update on gist.github.com

3. `ctrl-x ctrl-s` on any new (or temp) file will create a new gist

4. you can aslo delete a gist with command "glist:delete" or `ctrl-c ctrl-d`

now I can use Atom and gist in place of evernote :beer:
