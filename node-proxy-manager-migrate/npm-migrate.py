import os
import re
import requests
import logging

NPM_URL = "http://your-npm-ip:81"
NPM_EMAIL = "admin@example.com"
NPM_PASSWORD = "your-password"

NGINX_CONF_DIR = "/etc/nginx/sites-enabled"

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def get_npm_token():
    logging.info("Authenticating with Nginx Proxy Manager...")
    url = f"{NPM_URL}/api/tokens"
    payload = {
        "identity": NPM_EMAIL,
        "secret": NPM_PASSWORD
    }
    
    try:
        response = requests.post(url, json=payload, timeout=10)
        response.raise_for_status()
        token = response.json().get('token')
        logging.info("Authentication successful.")
        return token
    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching token: {e}")
        exit(1)

def parse_nginx_config(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    server_name_match = re.search(r'server_name\s+([^;]+);', content)
    proxy_pass_match = re.search(r'proxy_pass\s+(https?)://([^:/;]+)(?::(\d+))?[^;]*;', content)

    if not server_name_match or not proxy_pass_match:
        return None

    domains = server_name_match.group(1).strip().split()
    forward_scheme = proxy_pass_match.group(1)
    forward_host = proxy_pass_match.group(2)
    forward_port = proxy_pass_match.group(3)

    if not forward_port:
        forward_port = 80 if forward_scheme == 'http' else 443
    else:
        forward_port = int(forward_port)

    return {
        "domains": domains,
        "scheme": forward_scheme,
        "host": forward_host,
        "port": forward_port
    }

def create_proxy_host(token, config_data):
    url = f"{NPM_URL}/api/nginx/proxy-hosts"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "domain_names": config_data['domains'],
        "forward_scheme": config_data['scheme'],
        "forward_host": config_data['host'],
        "forward_port": config_data['port'],
        "access_list_id": "0",
        "certificate_id": "new",
        "meta": {
            "letsencrypt_email": "",
            "letsencrypt_agree": False
        },
        "advanced_config": "",
        "locations": [],
        "block_exploits": True,
        "caching_enabled": False,
        "allow_websocket_upgrade": True,
        "http2_support": False,
        "hsts_enabled": False,
        "hsts_subdomains": False,
        "ssl_forced": False
    }

    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        if response.status_code == 201:
            logging.info(f"Successfully created: {config_data['domains']} -> {config_data['host']}:{config_data['port']}")
        else:
            logging.warning(f"Failed to create {config_data['domains']}: {response.text}")
    except requests.exceptions.RequestException as e:
        logging.error(f"API connection error for domain {config_data['domains']}: {e}")

def main():
    token = get_npm_token()

    if not os.path.exists(NGINX_CONF_DIR):
        logging.error(f"Directory not found: {NGINX_CONF_DIR}")
        exit(1)

    for filename in os.listdir(NGINX_CONF_DIR):
        filepath = os.path.join(NGINX_CONF_DIR, filename)
        
        if os.path.isdir(filepath):
            continue

        logging.info(f"Processing file: {filename}")
        config_data = parse_nginx_config(filepath)

        if config_data:
            create_proxy_host(token, config_data)
        else:
            logging.warning(f"File {filename} skipped (no valid proxy_pass or server_name found).")

if __name__ == "__main__":
    main()

