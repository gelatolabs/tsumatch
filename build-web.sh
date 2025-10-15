#!/bin/sh
cd "$(dirname "$0")"
rm -rf build/web
love.js -t 'Tsumatch!' -c src build/web
rm -r build/web/theme
cp -r web build
