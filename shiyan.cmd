@echo off
if "%1" == "h" goto begin 
    mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit 
:begin
@REM 以下是你要启动的命令
python -V
@REM python manage.py runserver

@REM @echo off关闭运行框
@REM 注释的第一种方式
:: 注释的第二种方式
@echo hello dos!
@REM @echo 类似print
