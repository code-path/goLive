# goLive

**goLive** is a simple bash script tool that creates iOS 18 Live Photos with Live Wallpaper support using a MOV video file as input. The script processes the video, resizing it as needed, and generates a Live Photo that can be used as a Live Wallpaper on iOS 18.

This tool is perfect for anyone who wants to convert a video into a Live Photo with minimal effort, ideal for creating custom live wallpapers for iOS.

## Features

- **Resizes**: Automatically resizes videos to fit the necessary dimensions *(might stretch the output)*.
- **Lossless**: Ensures the highest possible quality by preserving all original data without any compression or degradation.
- **Ease to use**: Fully automated workflow with simple command-line usage.
- **Live Wallpaper Support**: Designed specifically for iOS 18 with live wallpaper support.
- **Converts MOV videos into Live Photos**: Creates a high-quality Live Photo from any MOV video.

### Requirements

| Requirement               | Version      | Description                                                                                                                                                                                                                            |
|---------------------------|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Bash**                  | 4.0+         | Shell environment to execute the script.                                                                                                                                                                                               |
| **libheif**               | 1.19.7       | libheif is an HEIF and AVIF file format decoder and encoder.                                                                                                                                                                           |
| **ExifTool**              | 13.10        | ExifTool is a platform-independent Perl library plus a command-line application for reading, writing and editing meta information in a wide variety of files.                                                                          |
| **ImageMagick**           | 7.1.1        | ImageMagick is a free, open-source software suite, used for editing and manipulating digital images.                                                                                                                                   |
| **GPAC (MP4Box)**         | 2.4          | The multimedia packager available in GPAC is called MP4Box. It is mostly designed for processing ISOBMF files (e.g. MP4, 3GP), but can also be used to import/export media from container files like AVI, MPG, MKV, MPEG-2 TS ...      |
| **FFmpeg/FFprobe**        | 7.1.1        | FFmpeg is a free and open-source software project consisting of a suite of libraries and programs for handling video, audio, and other multimedia files and streams.                                                                   |

### Install dependencies
To use goLive, you need to install the following dependencies:

1. Install **libheif**:
   ```bash
   brew install libheif
   ```

2. Install **ExifTool**:
   ```bash
   brew install exiftool
   ```

3. Install **ImageMagick**:
   ```bash
   brew install imagemagick
   ```

4. Install **GPAC (MP4Box)**:
   ```bash
   brew install gpac
   ```

5. Install **FFmpeg/FFprobe**:
   ```bash
   brew install ffmpeg
   ```

### Usage
Once the tool is set up, use the following command to create a Live Photo from your MOV video:

- Copy your MOV video to `input` directory and name it `input.mov`.
- Run the following command:
   ```bash
   bash /path/to/goLive.sh
   ```
- Once process finished, navigate to `output` directory and grab `IMG_XXXX.HEIC` and `IMG_XXXX.mov`.
- Use `AirDrop`, `iCloud`, or similar tools to transfer files to your iPhone Photos App.

### Contributing
Contributions are welcome! Please open an issue or create a pull request if you have any suggestions or improvements.

- Fork the repository
- Create a new branch (git checkout -b feature-branch)
- Make your changes
- Commit your changes (git commit -am 'Add new feature')
- Push to the branch (git push origin feature-branch)
- Create a new pull request