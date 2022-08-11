DIM objShell
set objShell=wscript.createObject("wscript.shell")
' 前提，你要把可执行文件的路径写对了
iReturn=objShell.Run("cmd.exe /C 1.bat", 0, TRUE)
iReturn=objShell.Run("cmd.exe /C 2.bat", 0, TRUE)
' 执行语句
iReturn=objShell.Run("powershell.exe /C python manage.py runserver", 0, TRUE)

' /C 执行字符串指定的命令然后终止，不保留窗口,推荐
' /K 执行字符串指定的命令但保留，保留窗口
