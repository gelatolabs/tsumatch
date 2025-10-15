#!/bin/sh
cd "$(dirname "$0")/src"
zip -9 -r ../build/tsumatch.love .
cd ..
