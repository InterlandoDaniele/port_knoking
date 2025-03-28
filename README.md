**PORT KNOCKING SETUP PER ACCESSO SSH SICURO**
Questa repository contiene script e file di configurazione per implementare un sistema di port knocking su un bastion host Linux, consentendo un accesso SSH sicuro e automatizzato da un client Windows. Il knocking apre la porta SSH del bastion, permettendo connessioni dirette o l'inoltro verso host interni (es. vm1).
**CONTENUTI DELLA REPOSITORY**
**script_install_config_port_knoking.sh**: Script Bash per installare e configurare il demone knockd sul bastion host.

**knock.bat**: Script batch per Windows che esegue la sequenza di knocking sul bastion.

**script.bat**: Script batch per Windows che esegue il knocking e si connette al bastion.

**.ssh/config**: File di configurazione SSH per automatizzare il knocking e le connessioni al bastion e agli host interni.

**A COSA SERVONO**
**script_install_config_port_knoking.sh**
Configura un server Linux come bastion host con il port knocking. Installa knockd, configura iptables per bloccare la porta SSH (22) di default e imposta una sequenza di porte (7000, 8000, 9000) per aprirla.
**knock.bat**
Esegue la sequenza di knocking (tentativi di connessione TCP alle porte 7000, 8000, 9000) per aprire la porta SSH sul bastion host. È progettato per essere chiamato automaticamente da altri script o comandi.
**script.bat**
Richiama knock.bat per eseguire il knocking e poi stabilisce una connessione SSH diretta al bastion. Serve come base per il ProxyCommand nel file .ssh/config.
**.ssh/config**
**Automatizza l'intero processo di connessione**:
**Per il bastion**: Esegue il knocking e si connette al bastion.

**Per vm1**: Usa il bastion come proxy per raggiungere l'host interno, con il knocking eseguito automaticamente.

**ISTRUZIONI PER L'USO**
**1. CONFIGURAZIONE DEL BASTION HOST**
Per configurare il bastion host con il port knocking:
Copia il file **script_install_config_port_knoking.sh** sul server Linux (bastion).

Esegui lo script con privilegi di root:
```
bash script_install_config_port_knoking.sh
```
Lo script:
Installa le dipendenze e compila knockd.

Configura iptables per bloccare tutto il traffico in ingresso tranne connessioni stabilite.

Imposta knockd con la sequenza 7000, 8000, 9000 per aprire la porta SSH e 9000, 8000, 7000 per chiuderla (opzionale).

Avvia il servizio knockd.

**2. CONFIGURAZIONE DEL CLIENT WINDOWS**
Per configurare il client Windows:
Assicurati di avere OpenSSH installato (disponibile su Windows 10/11 o tramite Git Bash).

Copia i file knock.bat, script.bat e .ssh/config nella directory ~/.ssh/ (es. C:\Users\<tuo_utente>\.ssh\).

Modifica i file con i dettagli reali:
**knock.bat**:
```
@echo off
echo Knocking on port 7000...
start /b telnet <bastion_ip> 7000
timeout /t 1 >nul
echo Knocking on port 8000...
start /b telnet <bastion_ip> 8000
timeout /t 1 >nul
echo Knocking on port 9000...
start /b telnet <bastion_ip> 9000
timeout /t 1 >nul
echo Knocking completed.
```
Sostituisci **<bastion_ip>** con l'IP del bastion.

**script.bat**:
```
@echo off
call knock.bat
echo Connecting to bastion...
ssh -i ~/.ssh/sshkey ec2-user@<bastion_ip>
```
Sostituisci **<bastion_ip>** con l'IP del bastion e, se necessario, modifica il percorso della chiave (~/.ssh/terraform) o il nome utente (ec2-user).

**.ssh/config**:
```
Host bastion
  HostName <bastion_ip>
  User ec2-user
  IdentityFile ~/.ssh/sshkey
  ProxyCommand cmd /c "call knock.bat && ssh -i ~/.ssh/sshkey ec2-user@%h -W %h:%p"

Host vm1
  HostName <vm1_ip>
  User ec2-user
  IdentityFile ~/.ssh/sshkey
  ProxyJump bastion
```
Sostituisci **<bastion_ip>** e **<vm1_ip>** con gli IP reali, e verifica il percorso della chiave (~/.ssh/sshkey) e il nome utente (ec2-user).

**3. CONNESSIONE**
Per connettersi al bastion:
```
ssh bastion
```
Per connettersi a vm1 attraverso il bastion:
```
ssh vm1
```
In entrambi i casi, il knocking viene eseguito automaticamente, la porta SSH del bastion si apre e la connessione procede.
**LOGICA DEL PORT KNOCKING**
Il port knocking nasconde la porta SSH (22) del bastion finché non viene ricevuta la sequenza corretta di "colpi" su porte specifiche:
Stato iniziale: La porta SSH è chiusa da iptables.

**Apertura**: La sequenza 7000, 8000, 9000 (in ordine) apre la porta SSH per l'IP del client.

**Connessione**: Dopo il knocking, SSH si connette al bastion e, se necessario, inoltra a vm1.

**Chiusura **(opzionale): La sequenza 9000, 8000, 7000 chiude la porta.

**VANTAGGI**
**Sicurezza**: La porta SSH è invisibile agli scanner di rete senza la sequenza corretta.

**Automazione**: Il knocking è integrato nel flusso SSH tramite .ssh/config.

**LIMITI**
Dipendenza da Telnet: knock.bat usa telnet, che potrebbe non essere disponibile su tutti i sistemi Windows moderni. In alternativa, considera un client come knock.exe.

**Timeout**: Il knocking deve completare entro il timeout di knockd (5 secondi di default).


**ESEMPI DI CONFIGURAZIONE**
**Esempio knock.bat**
```
@echo off
echo Knocking on port 7000...
start /b telnet 192.168.1.10 7000
timeout /t 1 >nul
echo Knocking on port 8000...
start /b telnet 192.168.1.10 8000
timeout /t 1 >nul
echo Knocking on port 9000...
start /b telnet 192.168.1.10 9000
timeout /t 1 >nul
echo Knocking completed.
```
**Esempio script.bat**
```
@echo off
call knock.bat
echo Connecting to bastion...
ssh -i ~/.ssh/sshkey ec2-user@192.168.1.10
```
**Esempio .ssh/config**
```
Host bastion
  HostName 192.168.1.10
  User ec2-user
  IdentityFile ~/.ssh/sshkey
  ProxyCommand cmd /c "call knock.bat && ssh -i ~/.ssh/sshkey ec2-user@%h -W %h:%p"

Host vm1
  HostName 192.168.1.100
  User ec2-user
  IdentityFile ~/.ssh/sshkey
  ProxyJump bastion
```
**CONCLUSIONE**
Questa repository ti permette di:
Configurare un bastion host con port knocking.

Automatizzare il knocking e l'accesso SSH da Windows usando knock.bat, script.bat e .ssh/config.

Connetterti a host interni (es. vm1) con un semplice comando ssh vm1.

Per un setup più robusto, considera di sostituire telnet con un client di knocking dedicato o di regolare i timeout se necessario.

