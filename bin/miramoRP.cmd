@ECHO OFF
set PATH=%~d0%~p0;%PATH%
mmClient.exe -user mmUser -password mmUser -networked Y -secure -port 443 -warn 2 %*
