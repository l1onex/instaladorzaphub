#!/bin/bash
# Script adaptado para Oracle Cloud Infrastructure (OCI)

set -e  # Interrompe o script se houver erro

# =============================
# Cores para saída colorida
# =============================
WHITE='\033[1;37m'
GRAY_LIGHT='\033[0;37m'
NC='\033[0m'

print_banner() {
    echo -e "${WHITE}==============================${NC}"
    echo -e "${WHITE}   Instalador ZapHub Oracle     ${NC}"
    echo -e "${WHITE}==============================${NC}"
}

check_vars() {
    if [ -z "$mysql_root_password" ] || \
       [ -z "$link_git" ] || \
       [ -z "$instancia_add" ] || \
       [ -z "$deploy_email" ]; then
        echo -e "${WHITE} ❌ Erro: As seguintes variáveis devem estar definidas:${NC}"
        echo -e "mysql_root_password link_git instancia_add deploy_email"
        exit 1
    fi
}

# =============================
# Cria usuário deploy
# =============================
system_create_user() {
    print_banner
    echo -e "${WHITE} 💻 Criando usuário 'deploy'...${NC}"
    sudo useradd -m -p $(openssl passwd -crypt "$mysql_root_password") -s /bin/bash -G sudo deploy
    sudo usermod -aG sudo deploy
    sleep 2
}

# =============================
# Atualiza sistema
# =============================
system_update() {
    print_banner
    echo -e "${WHITE} 💻 Atualizando sistema...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y libxshmfence-dev libgbm-dev wget unzip fontconfig locales gconf-service \
      libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 \
      libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
      libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 \
      libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
      ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
    sleep 2
}

# =============================
# Instala Node.js
# =============================
system_node_install() {
    print_banner
    echo -e "${WHITE} 💻 Instalando Node.js v22.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_22.x  | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g npm@latest
    sleep 2
}

# =============================
# Instala Docker
# =============================
system_docker_install() {
    print_banner
    echo -e "${WHITE} 💻 Instalando Docker...${NC}"
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg  | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ARCH=$(dpkg --print-architecture)
    CODENAME=$(lsb_release -cs)
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu  $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker deploy
    sleep 2
}

# =============================
# Instala PM2
# =============================
system_pm2_install() {
    print_banner
    echo -e "${WHITE} 💻 Instalando PM2...${NC}"
    sudo npm install -g pm2
    sleep 2
}

# =============================
# Instala Nginx
# =============================
system_nginx_install() {
    print_banner
    echo -e "${WHITE} 💻 Instalando Nginx...${NC}"
    sudo apt install -y nginx
    sudo rm -f /etc/nginx/sites-enabled/default
    sleep 2
}

# =============================
# Configura cliente_max_body_size no Nginx
# =============================
system_nginx_conf() {
    echo -e "${WHITE} 💻 Configurando Nginx...${NC}"
    echo 'client_max_body_size 100M;' | sudo tee /etc/nginx/conf.d/deploy.conf >/dev/null
    sleep 2
}

# =============================
# Reinicia Nginx
# =============================
system_nginx_restart() {
    echo -e "${WHITE} 💻 Reiniciando Nginx...${NC}"
    sudo systemctl restart nginx
    sleep 2
}

# =============================
# Instala Certbot (via APT)
# =============================
system_certbot_install() {
    echo -e "${WHITE} 💻 Instalando Certbot...${NC}"
    sudo apt install -y certbot python3-certbot-nginx
    sleep 2
}

# =============================
# Clona repositório Git
# =============================
system_git_clone() {
    echo -e "${WHITE} 💻 Clonando repositório...${NC}"
    sudo -u deploy git clone "$link_git" "/home/deploy/${instancia_add}/"
    sleep 2
}

# =============================
# Configura certificados SSL
# =============================
system_certbot_setup() {
    echo -e "${WHITE} 💻 Configurando Certbot...${NC}"
    backend_domain="${backend_url#https://}"
    frontend_domain="${frontend_url#https://}"
    sudo certbot -m "$deploy_email" --nginx --agree-tos --non-interactive --domains "$backend_domain,$frontend_domain"
    sleep 2
}

# =============================
# Função principal
# =============================
main() {
    check_vars
    system_create_user
    system_update
    system_node_install
    system_docker_install
    system_pm2_install
    system_nginx_install
    system_nginx_conf
    system_certbot_install
    system_git_clone
    system_nginx_restart
    system_certbot_setup
    echo -e "${WHITE} ✅ Instalação concluída com sucesso!${NC}"
}

main
