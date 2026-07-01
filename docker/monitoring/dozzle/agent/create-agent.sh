# Make dozzle to only answer to you server
sudo iptables -A DOCKER-USER -p tcp --dport 7007 -j DROP
sudo iptables -I DOCKER-USER -s 62.60.128.40 -p tcp --dport 7007 -j ACCEPT