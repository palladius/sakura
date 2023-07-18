#!/bin/bash

set -euo pipefail

YOUR_API_KEY="${YOUR_API_KEY:-provide-me-a-key}"

echo "------------------------------------------------------------------------------------------------"
echo "YOUR_API_KEY: '$YOUR_API_KEY'"
echo "If the above wrong, do: export YOUR_API_KEY='blah-blah' $(basename $0)"
echo 'Docs: https://developers.generativeai.google/tutorials/text_quickstart'
echo "------------------------------------------------------------------------------------------------"

#set -x

curl \
    -H 'Content-Type: application/json' \
    -d '{ "prompt": { "text": "Write a story about a magic backpack"} }' \
    "https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText?key=$YOUR_API_KEY"
