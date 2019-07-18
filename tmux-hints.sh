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

viewer="cat"
extension=".txt"
hint_path="$HOME/hints/"
verbose=false
quiet=false
header_init="# tmux-hints.sh\n"
repo="https://github.com/hozza/tmux-hints"
version="0.2"

while getopts 'o:x:p:vhq' flag; do
	case "${flag}" in
		o) viewer="${OPTARG}" ;;
		x) extension=".${OPTARG}" ;;
		p) hint_path="${OPTARG}" ;;
		v) verbose=true ;;
		q) quiet=true ;;
		h) 
			echo -e "$header_init\ntmux-hints.sh version $version Usage:\n\nSynopsis:\n\n\ttmux-hints.sh [SHORT-OPTION]\n\nOption [default] Description:\n\n\t-o\t[cat] hint file opener e.g. less|markdown\n\t-x\t[txt] hint file extension\n\t-p\t[$HOME/hints/] /path/to/hint/files/\n\t-v\tverbose\n\t-q\tquiet mode, hint only\n\t-h\tthis help text\n\nFor more help visit the repo: $repo"
			exit 2 
		;;
		*) break ;;
	esac
done

temp_file=$( mktemp  )
trap "rm -f $temp_file" EXIT

# make sure focus hooks are enabled
tmux set-option focus-events on

tmux set-hook pane-focus-in "run 'echo #{pane_current_command} > $temp_file'"


clear_term="\ec"
[ "$verbose" == true ] && clear_term=''

default="\nCreate a default hint file:\n\n"$hint_path"default"$extension"\n\nExit:\tCtrl+c\n\nUpdate:\t'git pull' in tmux-hint directory.\n\nHelp:\ttmux-hints.sh -h\n\nRepo:\t$repo\n"

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


