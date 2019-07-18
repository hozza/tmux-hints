# tmux-hints
Automatically show a cheat sheet or notes for any command focused in tmux. e.i. Show vim, zsh, tmux notes/key-combos in a pane when using them.

More info the blog post: https://benhoskins.dev/tmux-hints-sh-auto-cheatsheet-for-vim-zsh-tmux/

![tmux-hint.sh Screenshot](https://raw.githubusercontent.com/hozza/tmux-hints/master/tmux-hints-sh.png)

## Install

This is a bash script, you only need bash as a dependency _(which you probably already have)_ and whatever programme you'd like to show the hint file with, default is `cat`.

```bash
$ git clone https://github.com/hozza/tmux-hints.git
$ cd tmux-hints/
$ chmod +x ./tmux-hints.sh
$ ./tmux-hints.sh
```
## Usage

1. Make some 'hint files' - notes, cheat-sheets or memos for to show when using various commands and save them in `~/hints/`.

2. Run `./tmux-hints.sh` in a tmux pane of your choice.

3. Profit.

When you focus on another pane, running for example, `vim` .. The pane running `tmux-hints.sh` will automatically load your 'hint file' within 1 second, when you focus on something else, such as, `zsh` it'll show your zsh hint file without you having todo anything or pull-up a different notes file.

**What's a hint file?** I hear you ask, it's a text file of notes you've written and saved in `~/hints/`.

e.g. You could include key-combo/shortcut/custom-key-mappings of your new VIM/TMUX config, maybe also notes to remind you about some aspects of it's usage.

**Markdown?** If you have some sort of markdown viewer installed, and have md files as your hints. You can use the following:

`./tmux-hints.sh -o markdown -x md`

`-o markdown` specifies the `markdown` viewer/**o**pener you have installed (it uses `cat` by default).

`-x md` specify the hint file extension.

Taken some other path? If you have your notes/hints stored somewhere else you can specify a path with:

`./tmux-hints.sh -p ~/.dotfiles/hints/`

e.g. you have your hint files stored like so `~/.dotfiles/hints/vim.txt` 

## Not working?

Be gentle, this is my first attempt at bash scripting. 

Use the `-v` option to show what it's doing and hopefully where it's going wrong.

It uses tmux's built in hooks, specifically `pane-focus-in` and the tmux format expansion `#{pane_current_command}`. If you're running a bash script, tmux only returns 'bash' as the command not the script name. So you can't have hint files for specific scripts unfortunately _(just put script specific hints in your `~/hints/bash.txt` hint file and see them all at once)_

This does not come with the 'hint files' - as they are notes personal to you and your setup, and so you'll need to write some! e.g. If you have new vim plugins with custom maps that you can't quite remember just yet.
