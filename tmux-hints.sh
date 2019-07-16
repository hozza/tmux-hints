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
hint_path="~/hints/"
verbose=false

while getopts 'o:x:p:vh' flag; do
	case "${flag}" in
		o) viewer="${OPTARG}" ;;
		x) extension=".${OPTARG}" ;;
		p) hint_path="${OPTARG}" ;;
		v) verbose=true ;;
		h) 
			echo "# Usage: $@ -o=opener cat|less -x=extension md|txt -p=path /path/to/hint/files/ -v=verbose -h=help"
			exit 2 
		;;
		*) break ;;
	esac
done


temp_file=$( mktemp  )
trap "rm -f $temp_file" EXIT

tmux set-hook pane-focus-in "run 'echo #{pane_current_command} > $temp_file'"


clear_term="\ec"
[ "$verbose" == true ] && clear_term=''

### Set initial time of file
LTIME=`stat -c %Z $temp_file`

while true
do
	ATIME=`stat -c %Z $temp_file`

	if [[ "$ATIME" != "$LTIME" ]]
	then
		
		if [ "$verbose" == true ]; then 
			echo -e "# Command: $viewer $hint_path$( cat $temp_file )$extension\n\n"
		fi

		echo -ne "$clear_term$( $viewer $hint_path$( cat $temp_file )$extension )"
		LTIME=$ATIME
	fi
	sleep 1
done


