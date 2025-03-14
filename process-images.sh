#!/usr/bin/sh

################
# CONFIG
################

# DEFAULT CONFIGURATION
## Target widths for resizing
DEFAULT_WIDTH_IMAGE_LANDSCAPE="2560 1920 1600"
DEFAULT_WIDTH_IMAGE_PORTRAIT="1200 900 600"
DEFAULT_WIDTH_IMAGE_SQUARE="1200 900 600"

DEFAULT_WEBP_QUALITY=80
DEFAULT_AVIF_QUALITY="50%"

FILENAME_REGEX=".*input(\-.+)?\.(jpg|jpeg|png|webp|avif)"

# Check for config.sh in script's directory
SCRIPT_DIR=$(dirname "$0")
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    . "$SCRIPT_DIR/config.sh"
fi

################
# METHODS
################

# Function to determine image orientation
get_orientation() {
    local width=$1
    local height=$2

    if [ "$width" -gt "$height" ]; then
        echo "l"  # Landscape
    elif [ "$height" -gt "$width" ]; then
        echo "p"  # Portrait
    else
        echo "s"  # Square
    fi
}

# Process directory recursively
process_directory() {
    local dir="$1"

    # Find all image files in the directory and subdirectories
    # Find all image files with names that match the pattern input-* or input.*
    find "$dir" -type f -regextype posix-extended -regex $FILENAME_REGEX | while read -r img_file; do
        # Get directory where the image is located
        img_dir=$(dirname "$img_file")

        # Get image dimensions using identify from ImageMagick
        dimensions=$(identify -format "%w %h" "$img_file")
        width=$(echo $dimensions | cut -d' ' -f1)
        height=$(echo $dimensions | cut -d' ' -f2)

        WIDTH_IMAGE_LANDSCAPE=$DEFAULT_WIDTH_IMAGE_LANDSCAPE
        WIDTH_IMAGE_PORTRAIT=$DEFAULT_WIDTH_IMAGE_PORTRAIT
        WIDTH_IMAGE_SQUARE=$DEFAULT_WIDTH_IMAGE_SQUARE
        WEBP_QUALITY=$DEFAULT_WEBP_QUALITY
        AVIF_QUALITY=$DEFAULT_AVIF_QUALITY

        if [ -f "$img_dir/config.sh" ]; then
            . "$img_dir/config.sh"
        fi

        # Determine orientation
        orientation=$(get_orientation "$width" "$height")

        # Select width array based on orientation
        if [ "$orientation" = "l" ]; then
            WIDTHS="$WIDTH_IMAGE_LANDSCAPE"
        elif [ "$orientation" = "p" ]; then
            WIDTHS="$WIDTH_IMAGE_PORTRAIT"
        else
            WIDTHS="$WIDTH_IMAGE_SQUARE"
        fi

        # Process each target width
        for target_width in $WIDTHS; do
            # Skip if target width is greater than original width
            if [ "$target_width" -gt "$width" ]; then
                # create self-size variant. Just done check is not need because filename is already unique
                target_width=$width
            fi

            # Calculate height proportionally
            target_height=$(echo "scale=0; $target_width * $height / $width" | bc)

            # Check if WebP version already exists
            if [ ! -f "$img_dir/v${orientation}-w${target_width}.webp" ]; then
                gm convert "$img_file" -resize "${target_width}x${target_height}" \
                    -strip -quality $WEBP_QUALITY -define webp:method=6 \
                    "$img_dir/v${orientation}-w${target_width}.webp"
            fi

            # Check if AVIF version already exists
            if [ ! -f "$img_dir/v${orientation}-w${target_width}.avif" ]; then
                # Generate AVIF version
                convert "$img_file" -resize "${target_width}x${target_height}" \
                    -strip -quality $AVIF_QUALITY \
                    "$img_dir/v${orientation}-w${target_width}.avif"
            fi

        done
    done
}

################
# MAIN EXECUTION
################

# Check if directory parameter is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Process the provided directory
process_directory "$1"
