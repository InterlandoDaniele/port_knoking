@echo off
echo Knocking on port 7000...
start /b telnet <ip_macchina_con_port_knoking> 7000
timeout /t 1 >nul
echo Knocking on port 8000...
start /b telnet <ip_macchina_con_port_knoking> 8000
timeout /t 1 >nul
echo Knocking on port 9000...
start /b telnet <ip_macchina_con_port_knoking> 9000
timeout /t 1 >nul
echo Knocking completed.
