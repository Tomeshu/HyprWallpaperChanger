#!/bin/bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
wallpapers_dir="${script_dir}/wallpapers"
files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find "$wallpapers_dir" -type f ! -name "*.palette" -print0)

waybar_template=~/.config/waybar/waybar-colors.css

# History file to track wallpaper usage
history_file="${script_dir}/wallpaper_history.txt"

# Check if wallpapers directory exists; if not, create it
if [[ ! -d "$wallpapers_dir" ]]; then
    echo "Wallpapers directory not found, creating: $wallpapers_dir"
    mkdir -p "$wallpapers_dir"
fi

# Check if hyprpaper socket exists before proceeding
socket_dir="/run/user/$(id -u)/hypr/"
socket_path=$(find "$socket_dir" -name ".hyprpaper.sock" 2>/dev/null | head -n1)

if [[ ! -S "$socket_path" ]]; then
    echo "Error: hyprpaper socket not found or inaccessible."
    echo "Make sure hyprpaper is running inside your Hyprland session."
    exit 1
fi

index_file="${script_dir}/current_index.txt"
last_wallpaper_file="${script_dir}/last_wallpaper.txt"

valid_palettes=(
    dark dark16 darkcomp darkcomp16
    light light16 lightcomp lightcomp16
    harddark harddark16 harddarkcomp harddarkcomp16
    softdark softdark16 softdarkcomp softdarkcomp16
    softlight softlight16 softlightcomp softlightcomp16
)

validate_palette() {
    local p="$1"
    for valid in "${valid_palettes[@]}"; do
        if [[ "$p" == "$valid" ]]; then
            return 0
        fi
    done
    return 1
}

# Append wallpaper to history if different from last
append_history() {
    local wallpaper="$1"
    if [[ -f "$history_file" ]]; then
        last_entry=$(tail -n 1 "$history_file")
        if [[ "$last_entry" != "$wallpaper" ]]; then
            echo "$wallpaper" >> "$history_file"
        fi
    else
        echo "$wallpaper" > "$history_file"
    fi
}

set_wallpaper_by_index() {
    local idx=$1
    if (( idx < 0 || idx >= ${#files[@]} )); then
        echo "Index out of range"
        exit 1
    fi
    wallpaper_path="${files[$idx]}"
    echo "$idx" > "$index_file"
    echo "$wallpaper_path" > "$last_wallpaper_file"
    append_history "$wallpaper_path"
}

set_wallpaper_by_name() {
    local name=$1
    local file_path="${wallpapers_dir}/${name}"
    if [[ ! -f "$file_path" ]]; then
        echo "File not found: $file_path"
        exit 1
    fi
    wallpaper_path="$file_path"
    echo "$wallpaper_path" > "$last_wallpaper_file"
    for i in "${!files[@]}"; do
        if [[ "${files[$i]}" == "$file_path" ]]; then
            echo "$i" > "$index_file"
            break
        fi
    done
    append_history "$wallpaper_path"
}

assign_palette() {
    local image_name="$1"
    local palette="$2"
    local image_path

    if ! validate_palette "$palette"; then
        echo "Invalid palette: $palette"
        echo "Valid palettes are:"
        printf "  %s\n" "${valid_palettes[@]}"
        exit 1
    fi

    if [[ "$image_name" == "." ]]; then
        if [[ -f "$last_wallpaper_file" ]]; then
            image_path=$(<"$last_wallpaper_file")
        else
            echo "No current wallpaper set to assign palette to."
            exit 1
        fi
    else
        image_path="${wallpapers_dir}/${image_name}"
    fi

    local palette_file="${image_path}.palette"

    if [[ ! -f "$image_path" ]]; then
        echo "Image not found: $image_path"
        exit 1
    fi

    echo "$palette" > "$palette_file"
    echo "Assigned palette '$palette' to $image_path"
    wallpaper load
    clear
    exit 0
}

# Load current index or default to 0
if [[ -f "$index_file" ]]; then
    current_index=$(<"$index_file")
else
    current_index=0
fi

case $1 in
    set)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 set <filename> [palette]"
            exit 1
        fi
        set_wallpaper_by_name "$2"
        if [[ -n "$3" ]]; then
            assign_palette "$2" "$3"
        fi
        ;;

    index)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            set_wallpaper_by_index "$2"
        else
            echo "Usage: $0 index <number>"
            exit 1
        fi
        ;;

    random)
        random_index=$((RANDOM % ${#files[@]}))
        set_wallpaper_by_index "$random_index"
        ;;

    add)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 add <path-to-image> [palette]"
            exit 1
        fi
        if [[ ! -f "$2" ]]; then
            echo "File not found: $2"
            exit 1
        fi
        cp "$2" "$wallpapers_dir/"
        new_wallpaper_name=$(basename "$2")
        echo "Added wallpaper: $new_wallpaper_name"
        if [[ -n "$3" ]]; then
            assign_palette "$new_wallpaper_name" "$3"
        fi
        exit 0
        ;;

    back)
        if [[ ! -f "$history_file" ]]; then
            echo "No wallpaper history found."
            exit 1
        fi
        # Read last two entries from history
        last_wallpapers=($(tail -n 2 "$history_file"))
        if (( ${#last_wallpapers[@]} < 2 )); then
            echo "No previous wallpaper in history."
            exit 1
        fi
        # The previous wallpaper is the second last entry
        prev_wallpaper="${last_wallpapers[0]}"
        # Remove the last entry (current wallpaper) from history
        head -n -1 "$history_file" > "${history_file}.tmp" && mv "${history_file}.tmp" "$history_file"
        # Set wallpaper to previous
        if [[ ! -f "$prev_wallpaper" ]]; then
            echo "Previous wallpaper file not found: $prev_wallpaper"
            exit 1
        fi
        wallpaper_path="$prev_wallpaper"
        echo "$wallpaper_path" > "$last_wallpaper_file"
        # Update index_file to match the wallpaper index if found
        for i in "${!files[@]}"; do
            if [[ "${files[$i]}" == "$wallpaper_path" ]]; then
                echo "$i" > "$index_file"
                break
            fi
        done
        echo "Reverted to previous wallpaper: $wallpaper_path"
        ;;

    next)
        new_index=$((current_index + 1))
        if (( new_index >= ${#files[@]} )); then
            new_index=0
        fi
        set_wallpaper_by_index "$new_index"
        ;;

    load)
        if [[ -f "$last_wallpaper_file" ]]; then
            wallpaper_path=$(<"$last_wallpaper_file")
            for i in "${!files[@]}"; do
                if [[ "${files[$i]}" == "$wallpaper_path" ]]; then
                    echo "$i" > "$index_file"
                    break
                fi
            done
        else
            echo "No saved wallpaper found to load."
            exit 1
        fi
        ;;

    palette)
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: $0 palette <image|.> <palette>"
            exit 1
        fi
        assign_palette "$2" "$3"
        ;;

    *)
        echo "Usage: $0 {set <file> [palette]|index <num>|random|add <file> [palette]|back|next|load|palette <image|.> <palette>}"
        exit 1
        ;;
esac

# Preload the wallpaper for faster switching
echo "preloading $wallpaper_path"

hyprctl hyprpaper preload "$wallpaper_path"

# Set the wallpaper on all monitors
hyprctl hyprpaper wallpaper ",$wallpaper_path"

# Unload unused wallpapers to free memory
hyprctl hyprpaper unload unused

# Run your python script to convert colors
python_path="${script_dir}/convert_alpha.py"
python "${python_path}" "${waybar_template}"

# Apply color scheme
palette_config="${wallpaper_path}.palette"
if [[ -f "$palette_config" ]]; then
    wallust run --palette "$(cat "$palette_config")" "$wallpaper_path"
else
    wallust run "$wallpaper_path"
fi

# Restart waybar
pkill waybar
nohup waybar &>/dev/null &
