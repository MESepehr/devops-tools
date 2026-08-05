# Make dozzle to only answer to you server
sudo iptables -A DOCKER-USER -p tcp --dport 7007 -j DROP
sudo iptables -I DOCKER-USER -s 37.32.23.42 -p tcp --dport 3307 -j ACCEPT
sudo iptables -I DOCKER-USER -s 127.0.0.1 -p tcp --dport 3307 -j ACCEPT