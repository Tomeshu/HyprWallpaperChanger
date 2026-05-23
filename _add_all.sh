#!/bin/bash

# Get the directory where this script is located (which is also the target folder)
target_dir=$(dirname "$(realpath "$0")")

# Define the log file path inside the target folder
logfile="$target_dir/wallpaper_script.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$logfile"
}

log "Script started. Processing files in $target_dir"

# Loop through each regular file in the target directory
for file in "$target_dir"/*; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")

    # Skip the script itself and the log file
    if [[ "$filename" == "$(basename "$0")" ]] || [[ "$filename" == "$(basename "$logfile")" ]]; then
      log "Skipping file: $filename"
      continue
    fi

    # Get the relative path of the file from the script directory (which is target_dir)
    rel_path=$(realpath --relative-to="$target_dir" "$file")

    if wallpaper add "$rel_path"; then
      log "Added wallpaper: $rel_path"
      if rm "$file"; then
        log "Deleted file: $rel_path"
      else
        log "Failed to delete file: $rel_path"
      fi
    else
      log "Failed to add wallpaper: $rel_path"
    fi
  fi
done

log "Script finished."

