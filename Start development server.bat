@echo off
echo Serving src\public on port 8010, make sure the rebuild script is running...
echo.
twistd.py web --port 8010 --path src\public