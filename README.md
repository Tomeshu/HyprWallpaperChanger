# HyprWallpaperChanger

A simple app to change the theme and wallpaper of [Hyprland](https://github.com/hyprwm/Hyprland), a dynamic tiling Wayland compositor.

**HyprWallpaperChanger** makes it easy to cycle, set, and manage wallpapers and themes for your Hyprland-powered desktop using convenient Shell and Python scripts.

---

## Features

- Change wallpapers on demand or at intervals
- Apply custom or pre-defined themes (wallpapers + settings)
- Easy integration with Hyprland and common Linux workflows
- Scriptable and extendable

## Requirements

- **Hyprland** window manager ([GitHub](https://github.com/hyprwm/Hyprland))
- **Bash** or POSIX-compatible Shell (for `.sh` scripts)
- **Python 3.6+** (for Python scripts)
- Common utilities: `feh`, `swaybg`, or `hyprpaper` (depends on script implementation)
- Optional: `cron` or `systemd` for scheduling wallpaper changes

### Dependencies

You may need to install the following packages depending on your distribution and the specifics of the scripts:

- Shell:  
  - `bash` or `sh`
  - `coreutils` (for standard tools like `cp`, `mv`, etc.)
- Python:  
  - Python 3 (often `python3` and `pip`)
  - [python-dotenv](https://pypi.org/project/python-dotenv/) (if using `.env` files for configuration)

- Wallpaper tools (pick one, based on your usage):
  - [`feh`](https://feh.finalrewind.org/) — for setting wallpapers
  - [`swaybg`](https://github.com/swaywm/swaybg) — Wayland-native wallpaper tool
  - [`hyprpaper`](https://github.com/hyprwm/hyprpaper) — for native Hyprland wallpaper support

Install these via your package manager, for example:

```sh
# On Arch Linux:
sudo pacman -S feh python python-pip

# On Ubuntu/Debian:
sudo apt update
sudo apt install feh python3 python3-pip

# For hyprpaper (AUR for Arch):
yay -S hyprpaper
```

To install Python dependencies (if required):

```sh
pip install -r requirements.txt
# Or, if just python-dotenv is needed:
pip install python-dotenv
```

---

## Installation

1. **Clone the repository:**

```sh
git clone https://github.com/Tomeshu/HyprWallpaperChanger.git
cd HyprWallpaperChanger
```

2. **Configure your environment:**  
   Edit the settings or configuration files if present (e.g., `.env`, `config.sh`, or similar).  
   Make sure wallpaper directories and theme files suit your Hyprland setup.

3. **Make scripts executable:**

```sh
chmod +x *.sh
```

4. **Review and install dependencies** listed above.

---

## Usage

The usage instructions depend on how your scripts are named and structured. Assuming common conventions:

- **Change wallpaper:**  
  ```sh
  ./change_wallpaper.sh /path/to/wallpaper.jpg
  # or, if using a Python script
  python3 change_wallpaper.py --file /path/to/wallpaper.jpg
  ```
- **Apply a theme:**  
  ```sh
  ./apply_theme.sh mytheme
  ```
- **Randomize wallpaper:**  
  ```sh
  ./random_wallpaper.sh
  ```

See `--help` in each script for specifics, e.g.:
```sh
./change_wallpaper.sh --help
python3 change_wallpaper.py --help
```

> **Tip:** Integrate your scripts with your Hyprland config (`~/.config/hypr/hyprland.conf`) via exec directives or startup applications.

---

## Example Setup

**Automatically change wallpaper every 30 minutes using cron:**
```sh
crontab -e
# Add the line below (adjust the script path as necessary):
*/30 * * * * /path/to/HyprWallpaperChanger/random_wallpaper.sh
```

Or **add to Hyprland config** to set a wallpaper at startup:
```ini
exec = ~/HyprWallpaperChanger/change_wallpaper.sh ~/Pictures/wallpapers/space.jpg
```

---

## Customization

- Add your favorite wallpapers to a directory and point the script at it.
- Extend scripts for more advanced theme management.
- Use with notification tools (`notify-send`) for feedback.

---

## Contributing

Pull requests are welcome! Please open an issue to discuss any changes you’d like to make.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgments

- [Hyprland](https://github.com/hyprwm/Hyprland)
- [hyprpaper](https://github.com/hyprwm/hyprpaper)
- The open source Linux and Wayland community
