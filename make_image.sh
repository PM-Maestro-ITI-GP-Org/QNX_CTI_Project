#!/bin/bash
# Copyright (c) 2025, BlackBerry Limited. All rights reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
echo $SCRIPT_DIR

mkqnximage $* > $BUILD/output.txt 2>&1

if [ $? -ne 0 ]; then
    echo "Image generation is not successful ..."
    cat $BUILD/output.txt
    exit 1
fi

MISSING_SNIPPETS=$(grep "Warning: Host file '[0-9a-zA-Z_ \/\.\-]*' missing." $BUILD/output.txt)
if [[ ! -z "$MISSING_SNIPPETS" ]]; then
    echo "Image generation is not successful. Some files required for the image are missing.\nSee warnings below for details.\n"
    grep "Warning: Host file '[0-9a-zA-Z_ \/\.\-]*' missing." $BUILD/output.txt
    # An image was built but is likely incomplete due to missing files.
    # Delete it to avoid confusion.
    rm -rf $BUILD/*.img
    exit 1
else
    echo "Image generation is successful."
    exit 0
fi
