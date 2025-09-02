@echo off
echo Starting Paradise Resort Website locally...
echo.
echo Opening http://localhost:3000
echo Press Ctrl+C to stop the server
echo.
start http://localhost:3000
python -m http.server 3000