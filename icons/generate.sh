#!/bin/sh
# Generate Windows ICO, Apple Icon Image, iOS and Android icons from icon.png

set -e
cd "$(dirname "$0")"

# ICO
magick icon.png -define icon:auto-resize=256,128,64,48,32,16 icon.ico

# ICNS
mkdir -p /tmp/tsumatch.iconset
for size in 16 32 64 128 256 512 1024; do
    magick icon.png -resize ${size}x${size} /tmp/tsumatch.iconset/icon_${size}x${size}.png
done
for size in 32 64 256 512; do
    half=$((size/2))
    magick icon.png -resize ${size}x${size} /tmp/tsumatch.iconset/icon_${half}x${half}@2x.png
done
iconutil -c icns -o icon.icns /tmp/tsumatch.iconset
rm -rf /tmp/tsumatch.iconset

# iOS
mkdir -p ios.iconset
for size in 20 29 40 58 60 76 80 87 120 152 167 180 1024; do
    magick icon.png -resize ${size}x${size} ios.iconset/icon_${size}x${size}.png
done

# Android
mkdir -p android/mipmap-mdpi android/mipmap-hdpi android/mipmap-xhdpi android/mipmap-xxhdpi android/mipmap-xxxhdpi
magick icon.png -resize 48x48 android/mipmap-mdpi/icon.png
magick icon.png -resize 72x72 android/mipmap-hdpi/icon.png
magick icon.png -resize 96x96 android/mipmap-xhdpi/icon.png
magick icon.png -resize 144x144 android/mipmap-xxhdpi/icon.png
magick icon.png -resize 192x192 android/mipmap-xxxhdpi/icon.png
