# yt - fine-tuning the use of youtube-dl
Download music or video from e.g. YouTube, Soundcloud, Instagram, Facebook. For a full list of supported sites and services, see https://github.com/ytdl-org/youtube-dl/blob/master/docs/supportedsites.md.

![yt](https://user-images.githubusercontent.com/14880945/62221781-86e1b400-b3b2-11e9-873f-2dd323bcf154.gif)

## Description
[yt](https://github.com/ddelange/yt) is a pure-bash command-line tool that optimizes the use of [youtube-dl](https://github.com/ytdl-org/youtube-dl) for audio and videophiles with comprehensive and customizable presets, empirically tested on multiple streams. Maintains a download archive, to prevent duplicates when periodically downloading YouTube playlists or Soundcloud sets. Parses title ("%(artist)s - %(title)s") and retrieves a thumbnail, and injects these into file metadata. Adds the url id of the source to the filename, attempts to bypass geographical restrictions, and more.

#### Features include, but are not limited to:
- Parallel downloads
- Audio mode (default)
- Video mode (MKV `-vcodec copy` | MP4 AV1 | MP4 AVC)
- HDR video (MKV)
- Playlist mode (currently each playlist is download sequentially)
- Custom audio bitrate, video resolution, destination folder
- Embedded subtitle tracks
- Embedded metadata like chapter information and description

The audio streams in converted (video) files from `yt` will generally be of higher quality compared to [online alternatives](https://www.google.nl/search?q=youtube+to+mp3+online), while maintaining a comparable file size. This is achieved by preferring WAV/OPUS source streams, and by converting using the [Fraunhofer FDK AAC codec library](https://trac.ffmpeg.org/wiki/Encode/AAC#fdk_aac) at a bitrate of 256kbit/s (sufficient to encode a full 44.1kHz stream using `libfdk_aac` without losing detail at higher frequencies).
[![yt vs online](https://user-images.githubusercontent.com/14880945/62381156-246feb80-b54b-11e9-8445-3890c091d0c3.gif)](https://github.com/alexkay/spek)

## Installation
Dependencies are installations of `youtube-dl`, `atomicparsley`, and `ffmpeg` compiled using at least `--with-fdk-aac` (fdk-aac is GPL-incompatible, so this will produce an unredistributable distribution).

#### OSX
To install `yt` and its dependencies:
```bash
brew install ddelange/brewformulae/yt
```

Or manually (if you wish to avoid Homebrew, and install the dependencies yourself):
- Compile `ffmpeg` [including](https://trac.ffmpeg.org/wiki/CompilationGuide/macOS#Additionaloptions) `--with-fdk-aac`.
- [Install](https://github.com/ytdl-org/youtube-dl#installation) `youtube-dl`.
- Install [`atomicparsley`](https://github.com/wez/atomicparsley).
- Put [`yt`](yt/yt) in your path:
    ```bash
    git clone https://github.com/ddelange/yt.git ./yt
    cd ./yt && bash ./install.sh
    yt --help  # check that all is well
    ```

#### Debian/Ubuntu
On Linux, you can use [Homebrew](https://docs.brew.sh/Homebrew-on-Linux) as well:
```bash
brew install ddelange/brewformulae/yt
```

Or manually (if you wish to avoid Homebrew, and install the dependencies yourself):
- Compile `ffmpeg` including `--with-fdk-aac`. See example instructions, pick your favorite: [[1]](https://seanthegeek.net/455/how-to-compile-and-install-ffmpeg-4-0-on-debian-ubuntu/) [[2]](https://gist.github.com/rafaelbiriba/7f2d7c6f6c3d6ae2a5cb)
- [Install](https://github.com/ytdl-org/youtube-dl#installation) `youtube-dl`.
- Install [`atomicparsley`](https://github.com/wez/atomicparsley).
- Put [`yt`](yt/yt) in your path:
    ```bash
    git clone https://github.com/ddelange/yt.git ./yt
    cd ./yt && bash ./install.sh
    yt --help  # check that all is well
    ```

#### Windows
Easiest would be using the [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/about), and using instructions above. But since `youtube-dl` has dedicated Windows distributions available, you could try the following:

[untested, assumes you're running Bash for Windows]
- [Compile](https://github.com/jb-alvarado/media-autobuild_suite#information) `ffmpeg` including the `non-free tools` (which will contain `libfdk-aac`).
- Install `youtube-dl`:
    - [either] Assuming python / python3 and pip / pip3 are installed, run `sudo pip3 install youtube-dl` or `sudo pip3 install youtube-dl` respectively.
    - [or] Download [youtube-dl.exe](https://yt-dl.org/latest/youtube-dl.exe) and place it in any location on your [PATH](https://en.wikipedia.org/wiki/PATH_%28variable%29).
- Make sure `youtube-dl` is recognized by your shell by typing `youtube-dl --version`.
- Put [`yt`](yt/yt) in your path.

## Usage

tl;dr:
- Type `yt` to download m4a audio files for the (space separated) URL(s) fetched from clipboard (see also `-c`).
- Type `yt -vmM` to download video into mp4, up to 1080p, preferably with AVC codec for better compatibility.
- Type `yt -vHP 2160` to download best quality video into mkv, up to 4K HDR if available.

```
NAME
      yt - fine-tuning the use of youtube-dl.  Download music or video from e.g.  YouTube,
      Soundcloud,  Instagram,  Facebook.  For a full list of supported sites and services,
      see https://github.com/ytdl-org/youtube-dl/blob/master/docs/supportedsites.md

SYNOPSIS
      yt [OPTIONS] [URL] [URL...]

DESCRIPTION
      yt is a bash function that optimizes the use of youtube-dl for audio and videophiles
      with comprehensive and customizable presets, empirically tested on multiple streams.
      Maintains a  download archive,  to prevent duplicates when  periodically downloading
      YouTube playlists or Soundcloud sets.  Parses title  ("%(artist)s - %(title)s")  and
      retrieves a thumbnail, and injects these into file metadata.  Adds the url id of the
      source to the filename, and attempts to bypass geographical restrictions.

      youtube-dl  is a command-line program to download videos from  YouTube.com  and many
      more sites.  It requires the Python interpreter, version 2.6, 2.7, or 3.2+,  and  it
      is not platform specific.  It should work on your Unix box,  on Windows or on macOS.
      It is released to the public domain,  which means you can modify it, redistribute it
      or use it however you like.

REQUIREMENTS
      installations  of  youtube-dl  (e.g. "brew install youtube-dl")  and ffmpeg compiled
      with --enable-libfdk-aac (e.g. "brew install ffmpeg --with-fdk-aac").

OPTIONS
      -h, --help
            Print this help text and exit.

      -U
            Update  youtube-dl  to latest  version  and  exit.  Make  sure  that  you have
            sufficient permissions (run with sudo if needed).

      -s
            Enable silent mode (send stdout to /dev/null).

      -S
            Enable sequential mode.  Default behaviour: parallel mode.  The MAXPROCS (env)
            var sets parallelism  (default 4).  To download YouTube playlists in parallel,
            use e.g. "yt -v $(youtube-dl --get-id --flat-playlist <playlist-url>)".

      -f
            Force download, even when already recorded in --download-archive.

      -v
            Enable video mode. Defaults to audio mode. Only mono and stereo are supported.

      -c
            Fetch space separated  URLs from clipboard,  additional to the manually passed
            URLs. Auto-enables when no URLs are manually passed.

      -D POSIX_PATH
            Set the destination path.  Used for both the (intermediate) output and for the
            download archive. Defaults to  "~/Music/yt"  and  "~/Movies/yt"  for audio and
            video mode respectively. Override defaults with YT_MUSIC_DIR and YT_VIDEO_DIR.

      -p
            Enable playlist mode. When a video URL contains a reference to a playlist, the
            whole playlist will be  downloaded.  Will only download URLs that have not yet
            been recorded in the download archive.

      -k
            Keep original audio additionally.  In most cases, this will keep e.g. OPUS for
            YouTube, or LAME MP3 / WAV for Soundcloud URLs.  Ignored when -v is specified.

      -a KBITS_PER_SECOND
            Set the output audio bitrate. Defaults to 256kbit/s.

      -r HERTZ
            Set the output audio sampling rate. Defaults to 44100Hz.

      -P PIXELS
            Set the maximum height in pixels  of the video output.  Ignored when -v is not
            specified.  Defaults to 1080px.  Constraint is dropped when no formats comply.

      -m
            Use MP4 when merging audio/video streams, keeping video codecs if possible and
            converting audio to 256kbit/s AAC (resolving full 44.1KHz stream). If no merge
            is needed,  the (single) source file is kept  and no conversion is  performed.
            Default behaviour:  copy downloaded audio/video streams into an MKV container,
            using OPUS audio codec and  VP9 video codec for small filesizes.  Ignored when
            -v is not specified. For YouTube this will yield a maximum resolution of 1080.
            Sometimes,  AV1 streams will only be available up to a certain resolution.  In
            this case, specifying -M might yield higher resolution.

      -M
            Prefer the older AVC codec over AV1. Results in bigger file-sizes, but  better
            playback compatibility. Ignored when -v and -m are not specified.

      -H
            Prefer HDR streams. Tested on YouTube videos. Overrides -m.

BSD 3-Clause License

Copyright (c) 2019, ddelange
All rights reserved.
```
