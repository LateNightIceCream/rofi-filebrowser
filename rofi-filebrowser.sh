#!/bin/bash
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
##################################################################################


_exit()
{
        echo -en "\0prompt\x1fFiles\n"
        echo -en "\0message\x1f${path}\n"
        echo -en "\0no-custom\x1ftrue\n"
        exit
}

lsdir()
{
        if [ "x${ROFI_FB_SHOW_ICONS}" == "x1" ]
        then
                ls --color=never -d -a -p -1 "${1}"/{.,..,*} | \
                while IFS="" read -r key || [ -n "$key" ]; do
                        icon="$( ( file -E --mime-type -nNb "${key}" || mimetype --output-format='%m' "${key}" ) | tr '/' '-' )"
                        printf "${key}\0icon\x1f${icon}\n"
                done
        else
                ls --color=never -d -a -p -1 "${1}"/{.,..,*}
        fi
        echo -en "\0active\x1f${pos}\n"
}

use_parent()
{
        local parent="$(dirname "${path}")"
        pos=2
        for f in "${parent}"/*
        do
                if [ "${f}" == "${path}" ]
                then
                        break;
                fi
                (( pos++ ));
        done
        notify-send "Pos ${pos}"
        path="${parent}"
}

# Prepare escape color code samples.
# Two codes with different color arg are enough to find sample length and arg position.
# Single byte just covers maximum of 256 colors, which could be encoded in this way.

# FIXME: ls uses unexpected color codes, different from those, generated by tput.
# TERM type plays no role, can't continue.

#fg2=$( tput setaf 2 | od -An -t x1 )
#fg3=$( tput setaf 3 | od -An -t x1 )
#fg2a=( ${fg2} )
#fg3a=( ${fg3} )
#fglen=${#fg3a[@]}

#fgap = 0
#while (( fgap < fglen )); do
#        if (( ${fg3a[fgap]} != ${fg2a[fgap]} )); then
#                break
#        fi
#        (( fgap++ ))
#done
#fg_src=$( printf $(echo "${fg3: 0:$(( 3 * fgap ))}" | sed -e 's/ /\\x/g') )
#
#notify-send -u critical "Test" "fg2: ${fg2}\nfg3: ${fg3}\nfg2a: ${fg2a[*]}\nfg3a: ${fg3a[*]}\nfg_src: ${fg_src}"

# Main #

if ! [ -v ROFI_FB_SHOW_ICONS ]; then
        ROFI_FB_SHOW_ICONS=0
fi

pos=0

if   [ $# == 0 ]
then
        path=~
        lsdir ${path}
        _exit
fi

path="$(realpath "$1")"

if [ -d "${path}" ]
then
        if [ $(ls -1 "${path}" | wc -l ) == 0 ]
        then
                use_parent
        fi
else
        xdg-open "${path}" > /dev/null 2>&1 &
        use_parent
fi

lsdir "${path}"
_exit
