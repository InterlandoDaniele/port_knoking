**PORT KNOCKING SETUP PER ACCESSO SSH SICURO**
Questa repository contiene script e file di configurazione per configurare e utilizzare il port knocking come meccanismo di sicurezza per l'accesso SSH a un bastion host su una rete Linux, e successivamente per connettersi a host interni attraverso il bastion da un client Windows.
**CONTENUTI DELLA REPOSITORY**
La repository è composta dai seguenti file:
**script_install_config_port_knoking.sh**: Uno script Bash per installare e configurare il demone knockd su un server Linux (il bastion host). Configura il port knocking per controllare l'accesso alla porta SSH (22).

**script.bat**: Uno script batch per Windows che esegue la sequenza di knocking e poi stabilisce una connessione SSH al bastion, inoltrando la connessione a un host interno specificato.

**.ssh/config**: Un file di configurazione SSH di esempio per semplificare le connessioni al bastion e a una VM interna. (Nota: la configurazione fornita potrebbe richiedere correzioni.)

**A COSA SERVONO**
**script_install_config_port_knoking.sh**
Questo script configura un server Linux come bastion host con il port knocking abilitato. Il port knocking è una tecnica di sicurezza che mantiene una porta (in questo caso la porta SSH, 22) chiusa finché non viene ricevuta una sequenza specifica di "colpi" (tentativi di connessione) su porte predefinite. Una volta ricevuta la sequenza corretta, la porta SSH viene aperta per l'indirizzo IP del client.
**script.bat**
Questo script batch è pensato per utenti Windows. Esegue la sequenza di knocking sul bastion host utilizzando telnet per inviare pacchetti TCP alle porte specificate, quindi utilizza SSH per connettersi al bastion e inoltrare la connessione a un host interno (specificato come argomento).
**.ssh/config**
Questo file fornisce un esempio di configurazione SSH per semplificare l'accesso al bastion e a una VM interna attraverso il bastion. Tuttavia, la configurazione attuale presenta un possibile errore: il ProxyCommand per il bastion richiama script.bat, ma potrebbe non essere corretto in questo contesto (più dettagli sotto).
**ISTRUZIONI PER L'USO**
**1. CONFIGURAZIONE DEL BASTION HOST**
Per configurare il port knocking sul bastion host (un server Linux):
Copia il file script_install_config_port_knoking.sh sul bastion host.

**Esegui lo script con privilegi di root:**
```
bash script_install_config_port_knoking.sh
```
**Lo script eseguirà le seguenti operazioni:**
Aggiorna il sistema e installa le dipendenze (gcc, make, libpcap-devel, git, autoconf, automake, iptables-services).

Clona il repository di knockd, lo compila e lo installa.

Configura iptables per bloccare tutto il traffico in ingresso tranne le connessioni già stabilite e il loopback.

Imposta knockd con una configurazione che definisce:
Sequenza per aprire la porta SSH: 7000, 8000, 9000

Sequenza per chiudere la porta SSH: 9000, 8000, 7000

Crea e avvia un servizio systemd per knockd.

Al termine, il bastion host sarà configurato con il port knocking attivo sulla porta SSH.
**2. CONNESSIONE DAL CLIENT WINDOWS**
Per connettersi a un host interno attraverso il bastion da una macchina Windows:
Assicurati di avere SSH installato (ad esempio, OpenSSH per Windows).

Modifica script.bat sostituendo **<ip_macchina_con_port_knoking>** con l'IP effettivo del bastion host.

Esegui lo script passando l'IP e la porta dell'host interno come argomenti. Ad esempio, per connettersi a una VM interna (vm1) sulla porta 22:

script.bat 192.168.1.100 22

Lo script eseguirà la sequenza di knocking (7000, 8000, 9000) sul bastion usando telnet.

Dopo aver aperto la porta SSH sul bastion, si connetterà al bastion via SSH e inoltrerà la connessione all'host interno specificato (es. 192.168.1.100:22).

**3. CONFIGURAZIONE SSH**
Il file .ssh/config è un esempio di come configurare SSH per semplificare le connessioni. Tuttavia, la versione attuale potrebbe non essere completamente corretta. Ecco una spiegazione e una possibile correzione:
**CONFIGURAZIONE FORNITA**

Host bastion
  HostName <ip_macchina_bastion_knoking>
  User ec2-user
  IdentityFile ~/.ssh/sshkey
  ProxyCommand ~/.ssh/script.bat %h %p

Host vm1
  HostName <ip_vm_>
  User ec2-user
  IdentityFile ~/.ssh/sshkey
  ProxyCommand ssh -x -a -q bastion -W %h:%p


**LOGICA DEL PORT KNOCKING**
Il port knocking è un meccanismo di sicurezza che nasconde una porta (in questo caso la porta SSH, 22) finché non viene ricevuta una sequenza specifica di tentativi di connessione su porte predefinite. Ecco come funziona in questa repository:
**Stato iniziale:** La porta SSH (22) del bastion host è chiusa per tutti gli IP, grazie alle regole di iptables.

**Apertura della porta:** Per aprirla, il client deve inviare pacchetti TCP SYN alle porte 7000, 8000 e 9000 nell'ordine corretto. Il demone knockd rileva questa sequenza e modifica le regole di iptables per consentire l'accesso alla porta 22 dall'IP del client.

**Connessione:** Una volta aperta la porta, il client può connettersi al bastion via SSH e, se necessario, inoltrare la connessione a un host interno.

**Chiusura della porta:** La sequenza 9000, 8000, 7000 (opzionale) può essere usata per richiudere la porta.

**VANTAGGI**
Sicurezza aggiuntiva: La porta SSH non è visibile o accessibile agli scanner di rete finché non viene eseguita la sequenza corretta, riducendo il rischio di attacchi brute force.

Flessibilità: Una volta connessi al bastion, puoi accedere a host interni senza ulteriori knocking (assumendo che gli host interni non abbiano il proprio port knocking).

**LIMITI**
Manuale: Il knocking deve essere eseguito manualmente o integrato in modo più sofisticato nella configurazione SSH (ad esempio, con un client di knocking dedicato).

Dipendenza da Telnet: Su Windows, lo script usa telnet, che potrebbe non essere ideale o disponibile in tutte le installazioni.


**CONCLUSIONE**
Questa repository ti permette di:
Configurare un bastion host con port knocking per proteggere l'accesso SSH.

Connetterti dal tuo client Windows al bastion o a host interni usando uno script batch.

Usare una configurazione SSH per semplificare l'accesso (con possibili aggiustamenti).

Per un uso più avanzato, considera l'uso di un client di knocking dedicato (es. knock.exe) invece di telnet, o integra il knocking direttamente in un ProxyCommand compatibile con SSH su Windows.

