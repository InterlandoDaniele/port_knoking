#SCRIPT PER FARE KNOK E SSH PASSANDO PER UN BASTION 
@echo off
call knock.bat
echo Connecting to bastion...
ssh -i ~/.ssh/sshkey ec2-user@<ip_macchina_con_port_knoking>

