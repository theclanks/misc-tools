

##### Preparação Asterisk ##########################

echo "ids => notice" >> /etc/asterisk/logger.conf
asterisk -rx 'logger reload'

# Logrotate
echo -e "/var/log/asterisk/ids { \n   missingok \n   rotate 5 \n   daily \n   create 0640 asterisk asterisk  \n   postrotate \n   /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2> /dev/null \n endscript \n }" >> /etc/logrotate.d/asterisk

service syslog restart


#####################################################


############# Instalação e configuração #############

mkdir /usr/src/fail2ban

tar -xvzf fail2ban.tar.gz -C /usr/src/fail2ban

cd /usr/src/fail2ban

tar -xvjf fail2ban-0.8.4.tar.bz2

cd fail2ban-0.8.4

python setup.py install

cp files/redhat-initd /etc/init.d/fail2ban
chkconfig --add fail2ban

cp  ../jail.conf /etc/fail2ban/
cp  ../asterisk.conf /etc/fail2ban/filter.d/

nome=$(hostname | cut -d"." -f1)

sed -e "s/NOMEDOSERV/$nome/g" /etc/fail2ban/jail.conf > /etc/fail2ban/jail.conf.tmp

rm /etc/fail2ban/jail.conf
mv /etc/fail2ban/jail.conf.tmp /etc/fail2ban/jail.conf

####################################################

echo "Instalacao concluida ..."











