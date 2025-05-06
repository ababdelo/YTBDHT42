<h1 align="center">
YTBDHT42: YouTube Downloader Helper Tool
</h1>

![YTBDHT42](https://socialify.git.ci/ababdelo/YTBDHT42/image?font=Source+Code+Pro&language=1&name=1&owner=1&pattern=Circuit+Board&theme=Light)

<p align="center">
  <img src="https://img.shields.io/github/last-commit/ababdelo/YTBDHT42?style=flat-square-green" /> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/commit-activity/m/ababdelo/YTBDHT42?style=flat-square-yellow" /> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/followers/ababdelo" /> &nbsp;&nbsp;
  <img src="https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fababdelo%2FYTBDHT42&label=Repository%20Visits&countColor=%230c7ebe&style=flat&labelStyle=none"/> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/stars/ababdelo/YTBDHT42" /> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/contributors/ababdelo/YTBDHT42?style=flat-square" />
  <a href="https://github.com/yt-dlp/yt-dlp"><img src="https://img.shields.io/badge/dependency-yt--dlp-red"/></a>
  <a href="https://ffmpeg.org/"><img src="https://img.shields.io/badge/dependency-ffmpeg-blue"/></a>
</p>

## 📌 Table of Contents

- [📌 Table of Contents](#-table-of-contents)
- [✨ Features](#-features)
- [📦 Requirements](#-requirements)
- [🚀 Installation](#-installation)
- [🔄 Verify Installation](#-verify-installation)
- [🗑️ Uninstallation](#️-uninstallation)
- [🔧 Usage](#-usage)
  - [❓ Help](#-help)
  - [🎥 Download video](#-download-video)
  - [🎧 Download audio](#-download-audio)
  - [📂 Download playlist](#-download-playlist)
  - [🔍 List available medias](#-list-available-medias)
- [📝 License](#-license)
- [🤝 Contributing](#-contributing)
- [☎️ Contact](#️-contact)

## ✨ Features

- 📥 Download individual videos or full playlists with ease
- 🎛️ Simplifies `yt-dlp` usage into a guided experience
- 🖥️ Cross-platform support (Windows, Linux, macOS)
- 🔢 Interactive interface with numbered options
- ⚙️ Automatic configuration setup

## 📦 Requirements

Make sure the following dependencies are installed on your system:

- **Bash Shell**: Available on Linux, macOS, or Git Bash for Windows.
- **curl**: For downloading the script.
- **git**: For cloning the repository.
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) a powerful command-line program to download videos from YouTube and other sites.
- [`ffmpeg`](https://ffmpeg.org/) a complete solution to record, convert and stream audio and video.

## 🚀 Installation

You can install YTBDHT42 by running the following command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ababdelo/YTBDHT42/main/install.sh)
```

This will:

1. Clone the repo into `~/.ytbdht42`
2. Make `ytbdht42.sh` executable
3. Add an `alias ytbdht42="~/.ytbdht42/ytbdht42.sh"` to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.)
4. Reload your shell automatically

## 🔄 Verify Installation

To verify that YTBDHT42 is installed correctly, run:

```bash
ytbdht42 --version
```

This should display the version of YTBDHT42 you have installed.
If you see an error message like `command not found`, please restart your terminal or run `source ~/.bashrc` or `source ~/.zshrc` to apply the changes. Otherwise check your bash profile for the `ytbdht42` alias.

## 🗑️ Uninstallation

To remove YTB-DHT42 completely, run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ababdelo/YTBDht42/main/uninstall.sh)
```

This script will:

- Delete the `~/.ytbdht42` directory
- Remove the `alias ytbdht42="~/.ytbdht42/ytbdht42.sh"` line from your shell profiles.
- Restart your shell to apply changes

## 🔧 Usage

After installation, simply invoke:

```bash
ytbdht42 [options] <URL>
```

If you run `ytbdht42` with no arguments, the help text will be displayed.

### ❓ Help

To know more about the tools, its version and available options, and their usage, you can run:

```bash
ytbdht42 --help
```

| Flag                        | Description                                                                               | Default             |
| --------------------------- | ----------------------------------------------------------------------------------------- | ------------------- |
| `-s`, `--source <URL>`      | YouTube URL (video, channel, or playlist)                                                 | **required**        |
| `-d`, `--destination <dir>` | Output directory                                                                          | Current working dir |
| `-f`, `--format <fmt>`      | Format: `mp4`/`mkv`/`webm` (video) or `mp3`/`wav`/`m4a` (audio)                           | `mp4`               |
| `-r`, `--resolution <px>`   | Maximum video height (144,240,360,480,720,1080)                                           | `480`               |
| `-l`, `--list`              | List titles of a channel or playlist without downloading                                  | _off_               |
| `-p`, `--playlist`          | Force download of entire playlist, even if URL is a single video                          | _off_               |
| `-e`, `--subtitles [LANG]`  | Download and embed auto-generated subtitles. Optional `LANG` code (e.g. `en`, `ar`, `fr`) | `en`                |
| `-n`, `--name <t>`          | Custom media output filename (e.g. "`%(title)s.%(ext)s`")                                 | actual filename     |
| `-c`, `--count <N>`         | Limit playlist download to first `N` items                                                | _all_               |

### 🎥 Download video

To download a video, simply run:

```bash
ytbdht42 -s <URL> -d <destination> -f <format> -r <resolution>
```

For example, to download a video in `mp4` format with a resolution of `1080p`, run:

```bash
ytbdht42 -s <URL> -d ~/Downloads -f mp4 -r 1080
```

### 🎧 Download audio

To download audio, use the `-f` option with `mp3`, `wav`, or `m4a`:

```bash
ytbdht42 -s <URL> -d ~/Downloads -f mp3 -r 480
```

### 📂 Download playlist

To download a playlist, use the `-p` option:

```bash
ytbdht42 -p -s <URL> -d <destination> -f <format> -r <resolution>
```

You can also limit the number of videos downloaded from the playlist using the `-c` option:

```bash
ytbdht42 -p -s <URL> -d <destination> -f <format> -r <resolution> -c 5
```

This will download the first 5 videos from the playlist.

### 🔍 List available medias

To list the available videos in a channel or playlist without downloading them, use the `-l` option:

```shell
ytbdht42 -l -s <URL>
```

## 📝 License

This project is licensed under the **ED42 Non-Commercial License v1.0**. See the [LICENSE](license.md) file for more details.

## 🤝 Contributing

Contributions and suggestions to enhance this project are welcome! Please feel free to submit a pull request or open an issue.

## ☎️ Contact

For any inquiries or collaboration opportunities, please reach out to me at:

<p align="center" style="display: inline;">
    <a href="mailto:ababdelo.ed42@gmail.com"> <img src="https://img.shields.io/badge/Gmail-EA4335?style=flat&logo=gmail&logoColor=white"/></a>&nbsp;&nbsp;
    <a href="https://www.linkedin.com/in/ababdelo"> <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white"/></a>&nbsp;&nbsp;
    <a href="https://github.com/ababdelo"> <img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white"/></a>&nbsp;&nbsp;
    <a href="https://www.instagram.com/edunwant42"> <img src="https://img.shields.io/badge/Instagram-E4405F?style=flat&logo=instagram&logoColor=white"/></a>&nbsp;&nbsp;
</p>

<p align="center">Thanks for stopping by and taking a peek at my work!</p>
