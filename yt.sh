yt() {
  local usage="NAME
      yt - fine-tuning the use of youtube-dl.  Download music or video from e.g.  YouTube,
      Soundcloud,  Instagram,  Facebook.  For a full list of supported sites and services,
      see https://github.com/ytdl-org/youtube-dl/blob/master/docs/supportedsites.md

SYNOPSIS
      yt [OPTIONS] [URL] [URL...]

DESCRIPTION
      yt is a bash function that optimizes the use of youtube-dl for audio and videophiles
      with comprehensive and customizable presets, empirically tested on multiple streams.
      Maintains a  download archive,  to prevent duplicates when  periodically downloading
      YouTube playlists or Soundcloud sets.  Parses title  (\"%(artist)s - %(title)s\")  and
      retrieves a thumbnail, and injects these into file metadata.  Adds the url id of the
      source to the filename, and attempts to bypass geographical restrictions.

      youtube-dl  is a command-line program to download videos from  YouTube.com  and many
      more sites.  It requires the Python interpreter, version 2.6, 2.7, or 3.2+,  and  it
      is not platform specific.  It should work on your Unix box,  on Windows or on macOS.
      It is released to the public domain,  which means you can modify it, redistribute it
      or use it however you like.

REQUIREMENTS
      installations  of  youtube-dl  (e.g. \"brew install youtube-dl\")  and ffmpeg compiled
      with --enable-libfdk-aac (e.g. \"brew install ffmpeg --with-fdk-aac\").

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
            download archive. Defaults to  \"~/Music/yt\"  and  \"~/Movies/yt\"  for audio and
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

Copyright (c) 2019, ddelange
All rights reserved.
"
  local OPTIND  # https://stackoverflow.com/a/16655341/5511061
  local SILENT=false
  local PARALLEL=true
  local VIDEO_MODE=false
  local CLIPBOARD=false
  local CUSTOM_DESTINATION=false
  local PLAYLIST=false
  local KEEP_AUDIO=false
  local CUSTOM_AUDIO_BITRATE=false
  local AUDIO_BITRATE=257
  local MAX_PIXELS=1080
  local MP4=false
  local AVC=false
  local HDR=false
  local URLS=()

  # TODO
  # dependency check e.g. $(ffmpeg -codecs | grep -w libfdk_aac)

  # TODO
  # ~$ sudo yt -U
  # sudo: yt: command not found

  # TODO
  # Support playlists in parallel https://github.com/ytdl-org/youtube-dl/issues/3746#issuecomment-446694257

  # TODO
  # Support CC / subs (ffmpeg install using --with-srt)
  # --write-auto-sub --sub-lang "en,nl,de" --sub-format "srt/best" --embed-subs --convert-subs "srt"

  if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    set -- "-h"
  fi
  while getopts ":hUsSvcDpka:P:mMH" opt; do
    case $opt in
      U)
        sudo youtube-dl -U
        return;;
      h)
        echo "$usage" | less
        return;;
      s)
        SILENT=true
        ;;
      S)
        PARALLEL=false
        ;;
      v)
        VIDEO_MODE=true
        if ! $CUSTOM_AUDIO_BITRATE; then
          AUDIO_BITRATE=215
        fi
        ;;
      c)
        CLIPBOARD=true
        ;;
      D)
        CUSTOM_DESTINATION="$OPTARG"
        ;;
      p)
        PLAYLIST=true
        ;;
      k)
        KEEP_AUDIO=true
        ;;
      a)
        case $OPTARG in
          ''|*[!0-9]*)
            echo "-a: specify bitrate as integer. Type \"yt -h\" for more info."
            return
            ;;
          *)
            if [ $OPTARG -gt 1411 ]; then
              echo "-a: bitrate should not be greater than 1411kbit/s."
              return
            fi
            CUSTOM_AUDIO_BITRATE=true
            AUDIO_BITRATE=$OPTARG
            ;;
        esac
        ;;
      P)
        case $OPTARG in
          ''|*[!0-9]*)
            echo "-p: specify pixels as integer. Type \"yt -h\" for more info."
            return
            ;;
          *)
            if [ $OPTARG -lt 144 ]; then
              echo "-p: pixels should not be less than 144px."
              return
            fi
            MAX_PIXELS=$OPTARG
            ;;
        esac
        ;;
      m)
        MP4=true
        ;;
      M)
        AVC=true
        ;;
      H)
        HDR=true
        ;;
      \?)
        echo "Invalid option: -$OPTARG"
        return;;
      :)
        echo "Option -$OPTARG requires an argument. Type \"yt -h\" for more info."
        return;;
    esac
  done
  shift $((OPTIND -1))
  # get remaining arguments, treated as urls
  while test $# -gt 0; do
    URLS+=("$1")
    shift
  done

  if $CLIPBOARD || [ ${#URLS[@]} -eq 0 ]; then
    URLS=($(pbpaste))
  fi
  if ! $SILENT; then
    echo "${URLS[@]}"
  fi

  # set paths
  if ! $CUSTOM_DESTINATION; then
    if $VIDEO_MODE; then
      local destination="~/Movies/yt/"
    else
      local destination="~/Music/yt/"
    fi
  else
    local destination="$CUSTOM_DESTINATION"
    local len=$((${#destination}-1))
    if [ "${destination:len}" != "/" ]; then
      destination="${destination}/"
    fi
  fi

  # BASE_OPTIONS
  local BASE_OPTIONS=(--geo-bypass --ignore-config -i --add-metadata --metadata-from-title "%(artist)s - %(title)s")
  local output_filename="${destination}%(title)s %(id)s.%(ext)s"
  local download_archive="${destination}downloaded.txt"
  BASE_OPTIONS+=(-o "$output_filename")
  BASE_OPTIONS+=(--download-archive "$download_archive")
  if ! $PLAYLIST; then
    BASE_OPTIONS+=(--no-playlist)
  fi

  # DOWNLOAD_OPTIONS
  if $VIDEO_MODE; then
    if $HDR; then
      local DOWNLOAD_OPTIONS=(--merge-output-format mkv -f "(bestvideo[vcodec^=vp9][height<=${MAX_PIXELS}]/bestvideo[height<=${MAX_PIXELS}])+(bestaudio[acodec=opus]/bestaudio)/best[height<=${MAX_PIXELS}]")
    elif $MP4; then
      if [ $MAX_PIXELS -gt 1080 ] && ! $SILENT; then
        echo "Maximum resolution is set to ${MAX_PIXELS} and -m is present. Downloads will be limited to max 1080p on sites that don't provide higher resolution video streams in MP4 container (e.g. YouTube)."
      fi
      local DOWNLOAD_OPTIONS=(--merge-output-format "mp4" --postprocessor-args "-threads 0 -vcodec copy -acodec aac -b:a ${AUDIO_BITRATE}k -ar 44100")
      if $AVC; then
        DOWNLOAD_OPTIONS+=(-f "(bestvideo[vcodec^=avc][height<=${MAX_PIXELS}]/bestvideo"'[vcodec!^=vp9]'"[height<=${MAX_PIXELS}])+(bestaudio[acodec=opus]/bestaudio)/best[height<=${MAX_PIXELS}]")
      else
        DOWNLOAD_OPTIONS+=(-f "(bestvideo[vcodec^=av01][height<=${MAX_PIXELS}]/bestvideo[vcodec^=av][height<=${MAX_PIXELS}]/bestvideo"'[vcodec!^=vp9]'"[height<=${MAX_PIXELS}])+(bestaudio[acodec=opus]/bestaudio)/best[height<=${MAX_PIXELS}]")
      fi
    else
      local DOWNLOAD_OPTIONS=(--merge-output-format mkv -f "(bestvideo[vcodec=vp9][height<=${MAX_PIXELS}]/bestvideo[vcodec!=vp9.2][height<=${MAX_PIXELS}])+(bestaudio[acodec=opus]/bestaudio)/best[height<=${MAX_PIXELS}]")
    fi
  else
    local DOWNLOAD_OPTIONS=(--embed-thumbnail --audio-format m4a --audio-quality ${AUDIO_BITRATE}k --postprocessor-args "-ar 44100" -x -f "bestaudio[acodec=opus]/bestaudio/best")
    if $KEEP_AUDIO; then
      DOWNLOAD_OPTIONS+=(-k)
    fi
  fi


  # echo available formats for first URL
  if ! $SILENT; then
    youtube-dl -F --no-playlist "${URLS[0]}" || return
  fi
  # debug the command (non-parallel)
  # a=(youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[@]}")
  # echo ${a[@]}

  if $PARALLEL; then
    if $SILENT; then
      len=$((${#URLS[@]}-2))
      if [ $len -gt -1 ]; then
        for i in $(seq 0 $len); do
          (youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[i]}" > /dev/null &)
        done
      fi
      youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[$(($len+1))]}" > /dev/null
    else
      len=$((${#URLS[@]}-2))
      if [ $len -gt -1 ]; then
        for i in $(seq 0 $len); do
          (youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[i]}" &)
        done
      fi
      youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[$(($len+1))]}"
    fi
  else
    if $SILENT; then
      youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[@]}" > /dev/null
    else
      youtube-dl "${BASE_OPTIONS[@]}" "${DOWNLOAD_OPTIONS[@]}" "${URLS[@]}"
    fi
  fi
}

# yt -P 1440 -v -H ESxIaJWUtAs # will download 1440p mkv
# yt -P 1440 -v -m ESxIaJWUtAs # will download 1080p mp4
# yt -P 1440 -v -m 75fEhQlc9h4 # will download 480p mp4 av01
# yt -P 1440 -v -m -M 75fEhQlc9h4 # will download 1080p mp4 avc
# yt -ka 215 ESxIaJWUtAs 75fEhQlc9h4 # two audio files simultaneously at 215kbit/s + original audio files
