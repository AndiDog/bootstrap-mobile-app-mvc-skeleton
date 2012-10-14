@echo off
if not exist src\config-web.autogen.coffee goto confignotfound

cd src
call brunch test -c config-web.autogen.coffee
cd ..

goto end

:confignotfound

echo Error: Make sure the rebuild daemon ran at least once.

:end