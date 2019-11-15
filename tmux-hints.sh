#!/bin/bash
#
#	tmux-hints.sh by hozza
#
#	In a tmux pane run this script with:
#	'$ /path/to/tmux-hints.sh'
#
#	Use '$ /path/to/tmux-hints.sh -h' for help/usage.
#
#	When you focus (click/move) onto another pane
#	it'll show your cheat sheet for that command.
#
#	Useful for learning new shortcuts without flicking
#	though loads of txt/md notes.
#

export PATH=/usr/local/bin:/bin:/usr/bin
tag=${0##*/}

say () { echo "$tag: $@" ; }
die () { say "FATAL: $@" ; exit 1; }

# sanity check
case "$TMUX" in
	"") die "You need to be running tmux to use tmux-hints!" ;;
	*)  ;;
esac


header_init="# $tag\n"

viewer="cat"
extension=".txt"
hint_path="$HOME/hints/"
verbose=false
quiet=false
repo="https://github.com/hozza/tmux-hints"
version="0.3"

# help doc
help () {
	echo -e "$header_init"

	cat <<EndHelp
	$tag version $version usage:

	Synopsis:

		$tag [SHORT-OPTION]

	Option [default] Description:

		-h  this help text
		-o  [cat] hint file opener e.g. less|markdown
		-p  [$HOME/hints/] /path/to/hint/files/
		-q  quiet mode, hint only
		-v  verbose
		-x  [txt] hint file extension

	By default, it will try to cat $HOME/hints/tmux.txt, make sure this exists! :)
	For more help visit $repo
EndHelp
}



while getopts 'o:x:p:vhq' flag; do
	case "${flag}" in
		o) viewer="${OPTARG}" ;;
		x) extension=".${OPTARG}" ;;
		p) hint_path="${OPTARG}" ;;
		v) verbose=true ;;
		q) quiet=true ;;
		h) help; exit 2 ;;
		*) break ;;
	esac
done

temp_file=$( mktemp  )
trap "rm -f $temp_file" EXIT

# make sure focus hooks are enabled
tmux set-option focus-events on

tmux set-hook pane-focus-in "run 'echo #{pane_current_command} > $temp_file'"


clear_term="$(tput clear)"
[ "$verbose" == true ] && clear_term=''

default="\nCreate a default hint file:\n\n"$hint_path"tmux"$extension"\n\nExit:\tCtrl+c\n\nUpdate:\t'git pull' in tmux-hint directory.\n\nHelp:\ttmux-hints.sh -h\n\nRepo:\t$repo\n"

# init
if [ "$quiet" == true ]; then
	header_init=""
	default=""
fi
echo -e $clear_term$header_init
init=true


### Set initial time of file
LTIME=`stat -c %Z $temp_file`

# loop - checking for changes to tmp file
while true
do
	ATIME=`stat -c %Z $temp_file`

	if [ "$ATIME" != "$LTIME" ] || [ "$init" == true ]
	then
		
		this_hint=$( cat $temp_file )
		echo -ne $clear_term

		if [ "$init" == true ]; then this_hint="tmux"; fi
		init=false

		# show this hint
		header="$header_init"

		# verbose full command
		[ "$verbose" == true  ] && header=$header"# Exact Command Used: $viewer $hint_path$this_hint$extension\n"
		
		# hint exists? default hint?
		hint_exists=true
		if [ ! -f "$hint_path$this_hint$extension" ]; then
			
			# defaults?
			if [ -f $hint_path"tmux"$extension ]; then
				header=$header"# $this_hint hint not found.\n"
				this_hint="tmux"
			else
				header=$header"# tmux hint not found.\n"$default
				hint_exists=false;
			fi

		fi
		
		# output!
		if [ "$quiet" == false ]; then
			echo -e "$header# $this_hint$extension\n"
		fi	
		
		if [ "$hint_exists" == true ]; then
			echo -e "$( $viewer $hint_path$this_hint$extension )"
		fi

		LTIME=$ATIME
		
	fi
	sleep 1
done


