#!/bin/bash

# Cài Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Kiểm tra Flutter
flutter doctor

# Build web
flutter build web
