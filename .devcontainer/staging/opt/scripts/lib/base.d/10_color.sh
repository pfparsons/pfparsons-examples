#!/bin/false
color_reset="$(tput sgr0)"

if [ -z "$NO_COLOR" ]
then
    color_fg_gray="$(tput setaf 8)"
    color_fg_white="$(tput setaf 7)"
    color_fg_red="$(tput setaf 1)"
    color_fg_bright_red="$(tput setaf 9)"
    color_fg_green="$(tput setaf 2)"
    color_fg_bright_green="$(tput setaf 46)"
    color_fg_yellow="$(tput setaf 3)"
    color_fg_bright_yellow="$(tput setaf 11)"
    color_fg_blue="$(tput setaf 20)"
    color_fg_bright_blue="$(tput setaf 27)"

    color_bg_white="$(tput setaf 7)"
    color_bg_bright_white="$(tput setaf 15)"
    color_bg_gray="$(tput setaf 8)"
    color_bg_red="$(tput setab 1)"
    color_bg_yellow="$(tput setab 3)"
    color_bg_green="$(tput setab 41)"
    color_bg_gray="$(tput setab 8)"
fi
color::print_tables() {
    for i in $(seq "0" 64);
    do 
        printf "$(tput setaf $i) @#@ $(align::right 2 $i) @#@ $(tput sgr0)"
        if [ "$(( $i % 8 ))" -eq "0" ]
        then
            printf "\n"
        fi
    done

    for i in $(seq "0" 64);
    do 
        printf "$(tput setaf 15)$(tput setab $i) @#@ $(align::right 2 $i) @#@ $(tput sgr0)"
        if [ "$(( $i % 8 ))" -eq "0" ]
        then
            printf "\n"
        fi
    done
}


