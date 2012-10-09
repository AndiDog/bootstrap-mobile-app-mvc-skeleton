@echo off
echo Serving src\public on port 8003, make sure the rebuild script is running...
echo.
twistd.py web --port 8003 --path src\public