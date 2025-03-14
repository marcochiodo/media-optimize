# README.md - Image Processing Automation Script

## Overview

`process-images.sh` is a shell script that automates the optimization and conversion of images for web use. It recursively processes images in a directory, creating resized variants in WebP and AVIF formats based on the image orientation (landscape, portrait, or square).

## Features

- Automatic detection of image orientation (landscape, portrait, square)
- Customizable target widths for each orientation
- Resizing images while maintaining aspect ratio
- Converting to WebP and AVIF formats for improved web performance
- Configurable quality settings for each format
- Support for local configuration overrides

## Prerequisites

The script requires the following tools to be installed:

- ImageMagick (`convert` and `identify` commands)
- GraphicsMagick (`gm` command)
- `bc` for mathematical calculations
- Standard Unix utilities (`find`, `echo`, etc.)

## Installation

1. Download the `process-images.sh` script
2. Make it executable:
   ```bash
   chmod +x process-images.sh
   ```

## Usage

Run the script with a directory as the parameter:

```bash
./process-images.sh <directory>
```

The script will process all images in the specified directory and its subdirectories whose names match the pattern `input-*` or `input.*` with extensions `.jpg`, `.jpeg`, `.png`, `.webp`, or `.avif`.
This pattern is editable in the `config.sh` file setting `FILENAME_REGEX` variable.

## Configuration

### Default Configuration

The script comes with default settings:

- **Landscape images** will be resized to widths: 2560px, 1920px, 1600px
- **Portrait images** will be resized to widths: 1200px, 900px, 600px
- **Square images** will be resized to widths: 1200px, 900px, 600px
- **WebP quality**: 80
- **AVIF quality**: 50%

### Custom Configuration

You can override the default configuration in two ways:

1. Create a `config.sh` file in the same directory as the script
2. Create a `config.sh` file in any directory containing images to be processed

Configuration file example:

```bash
# Custom configuration
WIDTH_IMAGE_LANDSCAPE="2048 1536 1024"
WIDTH_IMAGE_PORTRAIT="1024 768 480"
WIDTH_IMAGE_SQUARE="1024 768 480"
WEBP_QUALITY=85
AVIF_QUALITY="60%"
```

Local directory configurations take precedence over the script's directory configuration.

## Output

For each original image (e.g., `input.jpg`), the script generates multiple variants:

- `vl-w2560.webp`, `vl-w1920.webp`, `vl-w1600.webp` (for landscape)
- `vp-w1200.webp`, `vp-w900.webp`, `vp-w600.webp` (for portrait)
- `vs-w1200.webp`, `vs-w900.webp`, `vs-w600.webp` (for square)

And corresponding `.avif` versions of each.

The filename format is:
- `v` followed by orientation code (`l` for landscape, `p` for portrait, `s` for square)
- `-w` followed by the width
- File extension (`.webp` or `.avif`)

## Behavior Notes

- The script skips creating variants that already exist
- If a target width is greater than the original width, the script will create a version at the original size
- For efficiency, the script uses high compression settings (WebP method 6)
- EXIF data is stripped from all output images

## Example

If you have a directory structure:

```
photos/
  ├── input.jpg               # 3000x2000 landscape image
  ├── events/
  │   ├── input-concert.jpg   # 1500x2500 portrait image
  │   └── config.sh           # Local config for the events directory
  └── products/
      └── input-square.jpg    # 1000x1000 square image
```

Running:
```bash
./process-images.sh photos
```

Will create:
```
photos/
  ├── input.jpg
  ├── vl-w2560.webp
  ├── vl-w2560.avif
  ├── vl-w1920.webp
  ├── vl-w1920.avif
  ├── vl-w1600.webp
  ├── vl-w1600.avif
  ├── events/
  │   ├── input-concert.jpg
  │   ├── config.sh
  │   ├── vp-w1200.webp
  │   ├── vp-w1200.avif
  │   ├── vp-w900.webp
  │   ├── vp-w900.avif
  │   ├── vp-w600.webp
  │   └── vp-w600.avif
  └── products/
      ├── input-square.jpg
      ├── vs-w1200.webp
      ├── vs-w1200.avif
      ├── vs-w900.webp
      ├── vs-w900.avif
      ├── vs-w600.webp
      └── vs-w600.avif
```

## License

This script is distributed under an open-source license. Feel free to modify and distribute it as needed.
