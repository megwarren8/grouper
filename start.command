#!/bin/bash
# Double-click to serve Grouper at http://localhost:8777 and open it in your browser.
cd "$(dirname "$0")"
PORT=8777
echo "Grouper — serving this folder at http://localhost:$PORT"
echo "Leave this window open while you use the app. Press Ctrl+C here to stop."
( sleep 1; open "http://localhost:$PORT/" ) &
exec python3 -m http.server "$PORT"
