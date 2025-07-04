cat ~/.cache/wallust/sequences

_wallpaper_complete() {
    local cur prev commands palettes wallpaper_dir files indexes
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    wallpaper_dir="$HOME/Projects/Bash/WallpaperChanger/wallpapers"

    commands="set index random add back next load palette"

    palettes="dark dark16 darkcomp darkcomp16 light light16 lightcomp lightcomp16 harddark harddark16 harddarkcomp harddarkcomp16 softdark softdark16 softdarkcomp softdarkcomp16 softlight softlight16 softlightcomp softlightcomp16"
    if [[ -d "$wallpaper_dir" ]]; then
        files=$(ls -1 "$wallpaper_dir")
    else
        files=""
    fi

    local count=$(echo "$files" | wc -l)
    indexes=""
    for ((i=0; i<count; i++)); do
        indexes+="$i "
    done

    if (( COMP_CWORD == 1 )); then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        set)
            if (( COMP_CWORD == 2 )); then
                COMPREPLY=( $(compgen -W "$files" -- "$cur") )
            elif (( COMP_CWORD == 3 )); then
                COMPREPLY=( $(compgen -W "$palettes" -- "$cur") )
            fi
            ;;
        index)
            if (( COMP_CWORD == 2 )); then
                COMPREPLY=( $(compgen -W "$indexes" -- "$cur") )
            fi
            ;;
        add)
            if (( COMP_CWORD == 2 )); then
                # Complete files from current directory for add <file>
                COMPREPLY=( $(compgen -f -- "$cur") )
            elif (( COMP_CWORD == 3 )); then
                COMPREPLY=( $(compgen -W "$palettes" -- "$cur") )
            fi
            ;;
        palette)
            if (( COMP_CWORD == 2 )); then
                COMPREPLY=( $(compgen -W ". $files" -- "$cur") )
            elif (( COMP_CWORD == 3 )); then
                COMPREPLY=( $(compgen -W "$palettes" -- "$cur") )
            fi
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _wallpaper_complete wallpaper

export PATH="/home/tomas/Projects/Bash/WallpaperChanger/:$PATH"

