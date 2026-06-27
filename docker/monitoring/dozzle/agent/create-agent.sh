# Make dozzle to only answer to you server
sudo iptables -A DOCKER-USER -p tcp --dport 7007 -j DROP
sudo iptables -I DOCKER-USER -s 185.213.164.210 -p tcp --dport 7007 -j ACCEPT