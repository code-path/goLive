#!/bin/bash

# DIR: Set the current directory
DIR=$(pwd)

# UUID: Generate a unique identifier
UUID=$(uuidgen)

# Name: Generate a random 4-digit number
NAME=$(printf "%04d" $((RANDOM % 10000)))

# Debug: Enable or disable debug mode
DEBUG=1

# Base: Define file names and paths
BASE_MOV="$DIR/base/base.mov"
BASE_HEIC="$DIR/base/base.HEIC"

# Input: Define file names and paths
INPUT_MOV="$DIR/input/input.mov"

# Output: Define file names and paths
OUTPUT_MOV="$DIR/output/IMG_${NAME}.mov"
OUTPUT_PNG="$DIR/output/IMG_${NAME}.png"
OUTPUT_HEIC="$DIR/output/IMG_${NAME}.HEIC"
OUTPUT_TRACK="$DIR/output/IMG_${NAME}.h264"
OUTPUT_METADATA=("$DIR/output/[DEBUG-METADATA]base_mov.json" "$DIR/output/[DEBUG-METADATA]base_HEIC.json" "$DIR/output/[DEBUG-METADATA]input_mov.json" "$DIR/output/[DEBUG-METADATA]output_mov.json" "$DIR/output/[DEBUG-METADATA]output_HEIC.json")

# Dependency: Check if FFmpeg, MP4Box, ImageMagick, and ExifTool are installed
if ! command -v ffmpeg &> /dev/null || ! command -v MP4Box &> /dev/null || ! command -v magick &> /dev/null || ! command -v exiftool &> /dev/null; then
    echo "FFmpeg (with ffprobe), MP4Box, ImageMagick (magick), or ExifTool is not installed. Please install them."
    exit 1
fi

# Base: Check if files are present
if [ ! -f "$BASE_MOV" ] || [ ! -f "$BASE_HEIC" ]; then
    echo "Base live photo not found!"
    exit 1
fi

# Input: Check if files are present
if [ ! -f "$INPUT_MOV" ]; then
    echo "Input data not found!"
    exit 1
fi

# Clear: Previously generated files
rm -rf "$DIR/output/"*

# Copy: Input to output
cp "$INPUT_MOV" "$OUTPUT_MOV"

# Base width: Extract from the base MOV using ffprobe
BASE_WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$BASE_MOV" | tr -d '[:space:],')

# Base height: Extract from the base MOV using ffprobe
BASE_HEIGHT=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$BASE_MOV" | tr -d '[:space:],')

# Base duration: Extract from the base MOV using ffprobe
BASE_DURATION=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$BASE_MOV")

# Base frame rate: Extract from the base MOV using ffprobe
BASE_FRAMERATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$BASE_MOV" | awk -F'/' '{print $1/$2}')

# Input duration: Extract from the input MOV using ffprobe
INPUT_DURATION=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$INPUT_MOV")

# Speed factor: Calculate the speed factor to match the base duration
SPEED_FACTOR=$(echo "$BASE_DURATION / $INPUT_DURATION" | bc -l)

# Output: Set scale, frame rate, and duration of output MOV
ffmpeg -i "$OUTPUT_MOV" -vf "scale=${BASE_WIDTH}:${BASE_HEIGHT},setsar=1,setdar=${BASE_WIDTH}/${BASE_HEIGHT},setpts=${SPEED_FACTOR}*PTS" -r "$BASE_FRAMERATE" \
    -c:v libx265 -crf 0 -preset veryslow -tag:v hvc1 \
    -c:a copy -map_metadata -1 -metadata creation_time="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    "${OUTPUT_MOV%.mov}_adjusted.mov" -y
mv "${OUTPUT_MOV%.mov}_adjusted.mov" "$OUTPUT_MOV"

# Output: MAGIC HAPPENS HERE...
MP4Box -raw 1 "$OUTPUT_MOV" -out "$OUTPUT_TRACK"
MP4Box -add "$OUTPUT_TRACK" -add "$BASE_MOV" -new "$OUTPUT_MOV"

# Output: Generate still image
ffmpeg -i "$OUTPUT_MOV" -vf "fps=1" -ss "$(ffmpeg -i "$OUTPUT_MOV" 2>&1 | awk -F '[:, ]+' '/Duration/ {print ($2*3600) + ($3*60) + $4; exit}' | awk '{print $1/2}')" -frames:v 1 -update 1 -compression_level 0 -pred none "$OUTPUT_PNG"

# Output: Extract base HEIC ICC profile and add it to output HEIC | Convert output PNG to HEIC format
exiftool -icc_profile -b "$BASE_HEIC" > /tmp/temp.icc && [ -s /tmp/temp.icc ] && PROFILE_OPTION="-profile /tmp/temp.icc" || PROFILE_OPTION=""; magick "$OUTPUT_PNG" -depth 10 -quality 100 -define heic:lossless=true $PROFILE_OPTION "$OUTPUT_HEIC"; rm -f /tmp/temp.icc "$OUTPUT_PNG"

# Output: Force writing of all tags from base to output
exiftool -ee3 -TagsFromFile "$BASE_MOV" -all:all "$OUTPUT_MOV" -overwrite_original -m -F -ignoreMinorErrors
exiftool -ee3 -TagsFromFile "$BASE_HEIC" -all:all "$OUTPUT_HEIC" -overwrite_original -m -F -ignoreMinorErrors

# Output: Add additional metadata to output MOV
exiftool -api QuickTimeUTC \
    -QuickTime:CreateDate="2025:03:08 08:42:07" \
    -QuickTime:ModifyDate="2025:03:08 08:42:07" \
    -QuickTime:TrackCreateDate="2025:03:08 08:42:07" \
    -QuickTime:TrackModifyDate="2025:03:08 08:42:07" \
    -QuickTime:MediaCreateDate="2025:03:08 08:42:07" \
    -QuickTime:MediaModifyDate="2025:03:08 08:42:07" \
    -SubSecCreateDate="2025:03:08 08:42:07.000" \
    -QuickTime:ContentIdentifier="$UUID" \
    -Apple:ContentIdentifier="$UUID" \
    -Apple:ImageUniqueID="$UUID" \
    -LivePhotoAuto=1 \
    -LivePhotoVitalityScore=1 \
    -LivePhotoVitalityScoringVersion=4 \
    -LivePhotoVideoIndex="1" \
    "$OUTPUT_MOV"

# Output: Add additional metadata to output HEIC
exiftool -api QuickTimeUTC \
    -QuickTime:CreateDate="2025:03:08 08:42:07" \
    -QuickTime:ModifyDate="2025:03:08 08:42:07" \
    -QuickTime:TrackCreateDate="2025:03:08 08:42:07" \
    -QuickTime:TrackModifyDate="2025:03:08 08:42:07" \
    -QuickTime:MediaCreateDate="2025:03:08 08:42:07" \
    -QuickTime:MediaModifyDate="2025:03:08 08:42:07" \
    -SubSecCreateDate="2025:03:08 08:42:07.000" \
    -QuickTime:ContentIdentifier="$UUID" \
    -Apple:ContentIdentifier="$UUID" \
    -Apple:ImageUniqueID="$UUID" \
    -LivePhotoVideoIndex="0" \
    "$OUTPUT_HEIC"

# DEBUG
if [ "$DEBUG" -eq 1 ]; then
    exiftool -ee3 -G -b -json "$BASE_MOV" > "${OUTPUT_METADATA[0]}"
    exiftool -ee3 -G -b -json "$BASE_HEIC" > "${OUTPUT_METADATA[1]}"
    exiftool -ee3 -G -b -json "$INPUT_MOV" > "${OUTPUT_METADATA[2]}"
    exiftool -ee3 -G -b -json "$OUTPUT_MOV" > "${OUTPUT_METADATA[3]}"
    exiftool -ee3 -G -b -json "$OUTPUT_HEIC" > "${OUTPUT_METADATA[4]}"

    echo "-------------------------------------------------------------------------------------"
    echo "UUID: $UUID"
    echo "-------------------------------------------------------------------------------------"
    exiftool "$OUTPUT_MOV"
    echo "-------------------------------------------------------------------------------------"
    exiftool "$OUTPUT_HEIC"
    echo "-------------------------------------------------------------------------------------"
fi

echo "Process completed successfully."
