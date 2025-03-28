#!/bin/bash
# Aggiorna il sistema e installa le dipendenze
yum update -y
yum install -y gcc make libpcap-devel git autoconf automake iptables-services

# Scarica e compila knockd
git clone https://github.com/jvinet/knock.git
cd knock
autoreconf -fi
./configure
make
make install

# Verifica l'installazione
/usr/local/sbin/knockd --version

# Configura iptables
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables-save > /etc/sysconfig/iptables
systemctl enable iptables
systemctl start iptables

# Configura knockd
cat << EOF > /etc/knockd.conf
[openSSH]
sequence    = 7000,8000,9000
seq_timeout = 5
command     = /sbin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
tcpflags    = syn

[closeSSH]
sequence    = 9000,8000,7000
seq_timeout = 5
command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
tcpflags    = syn
EOF

# Identifica l'interfaccia di rete
INTERFACE=$(ip link | grep -oP '(?<=2: ).*?(?=:)')
echo "Interfaccia di rete rilevata: $INTERFACE"

# Crea il servizio systemd
cat << EOF > /etc/systemd/system/knockd.service
[Unit]
Description=Port Knocking Daemon
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/knockd -c /etc/knockd.conf -i $INTERFACE -v
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Avvia il servizio
systemctl daemon-reload
systemctl enable knockd
systemctl start knockd

# Verifica lo stato
systemctl status knockd

echo "Installazione e configurazione di knockd completata!"
