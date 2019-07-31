# yt - fine-tuning the use of youtube-dl
Download music or video from e.g. YouTube, Soundcloud, Instagram, Facebook. For a full list of supported sites and services, see https://github.com/ytdl-org/youtube-dl/blob/master/docs/supportedsites.md.

![yt](https://user-images.githubusercontent.com/14880945/62221781-86e1b400-b3b2-11e9-873f-2dd323bcf154.gif)

## Description
yt is a bash function that optimizes the use of youtube-dl for audio and videophiles with comprehensive and customizable presets, empirically tested on multiple streams. Maintains a download archive, to prevent duplicates when periodically downloading YouTube playlists or Soundcloud sets. Parses title ("%(artist)s - %(title)s") and retrieves a thumbnail, and injects these into file metadata. Adds the url id of the source to the filename, attempts to bypass geographical restrictions, and more.

#### Features include, but are not limited to:
- Parallel downloads
- Audio mode (default)
- Video mode (MKV `-vcodec copy` | MP4 AV1 | MP4 AVC)
- HDR video (MKV)
- Playlist mode (currently each playlist is download sequentially)
- Custom audio bitrate, video resolution, destination folder

## Installation
Dependencies are installations of `youtube-dl`, `atomicparsley`, and `ffmpeg` compiled using at least `--with-fdk-aac`.

#### OSX
If `--enable-gpl` is specified, `--enable-nonfree` must also be specified to work using `--with-fdk-aac`.
```bash
brew tap varenc/ffmpeg  # https://trac.ffmpeg.org/wiki/CompilationGuide/macOS#Additionaloptions
brew install varenc/ffmpeg/ffmpeg --with-fdk-aac --with-srt --with-wavpack --with-xvid
brew install atomicparsley youtube-dl
sudo youtube-dl -U
git clone https://github.com/ddelange/yt.git ./yt
echo "source '$(pwd)/yt/yt.sh'" >> ~/.bashrc  # and restart shell
```

#### Debian/Ubuntu
- Compile `ffmpeg` including `--with-fdk-aac`. See example instructions, pick your favorite: [[1]](https://seanthegeek.net/455/how-to-compile-and-install-ffmpeg-4-0-on-debian-ubuntu/) [[2]](https://gist.github.com/rafaelbiriba/7f2d7c6f6c3d6ae2a5cb)
- [Install](https://github.com/ytdl-org/youtube-dl#installation) `youtube-dl`:
```bash
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
sudo youtube-dl -U
git clone https://github.com/ddelange/yt.git ./yt
echo "source '$(pwd)/yt/yt.sh'" >> ~/.bashrc  # and restart shell
```

#### Windows
[untested, assumes you're running Bash for Windows]
- [Compile](https://github.com/jb-alvarado/media-autobuild_suite#information) `ffmpeg` including the `non-free tools` (which will contain `libfdk-aac`).
- Install `youtube-dl`:
    - [either] Assuming python / python3 and pip / pip3 are installed, run `sudo pip3 install youtube-dl` or `sudo pip3 install youtube-dl` respectively.
    - [or] Download [youtube-dl.exe](https://yt-dl.org/latest/youtube-dl.exe) and place it in any location on your [PATH](https://en.wikipedia.org/wiki/PATH_%28variable%29).
- Make sure `youtube-dl` is recognized by your shell by typing `youtube-dl --version`.
- Add [`yt.sh`](https://github.com/ddelange/yt/blob/master/yt.sh) to your bash profile / bashrc, and restart your shell.

## Usage
Type `yt -h` to print the following text and exit. Type `yt` to download audio files for the (space separated) URL(s) fetched from clipboard.
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
      source to  the filename,  attempts to  bypass geographical  restrictions,  and more.

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
            Enable silent mode.

      -S
            Enable sequential mode. Default behaviour: parallel mode (send to background).
            Playlists are downloaded sequentially, as youtube-dl does not support parallel
            downloading of playlists (see #3746).

      -v
            Enable video mode. Defaults to audio mode. Only mono and stereo are supported.

      -c
            Fetch space separated  URLs from clipboard.  Overwrites manually  passed URLs.
            Auto-enables when no URLs are manually passed.

      -D POSIX_PATH
            Set the destination path.  Used for both the (intermediate) output and for the
            download archive. Defaults to  "~/Music/yt"  and  "~/Movies/yt"  for audio and
            video mode respectively.

      -p
            Enable playlist mode. When the input URL contains reference to a playlist, the
            whole playlist will be  downloaded.  Will only download URLs that have not yet
            been recorded in the download archive.

      -k
            Keep original audio additionally.  In most cases, this will keep e.g. OPUS for
            YouTube, or LAME MP3 / WAV for Soundcloud URLs.  Ignored when -v is specified.

      -a KBITS_PER_SECOND
            Set the output audio bitrate.  Defaults to 256kbit/s (and 215kbit/s with -vm).

      -P PIXELS
            Set the maximum height in pixels  of the video output.  Ignored when -v is not
            specified. Defaults to 1080px.

      -m
            Use MP4 when merging (converting) audio/video streams, keeping video codecs if
            possible and converting audio codecs to 215kbit/s AAC (resolving 40KHz waves).
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

Copyright (c) 2019, David de Lange
All rights reserved.
```
