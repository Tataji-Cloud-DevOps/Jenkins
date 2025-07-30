#!/bin/bash 
: <<'COMMENT'
if [ $(id -u) -ne 0 ]; then 
    echo -e "You should perform this as root user"
    exit 1
fi 
Stat() {
    if [ $1 -ne 0 ]; then 
        echo "Installation Failed :  Check log /tmp/jinstall.log"
        exit 2 
    fi 
}

yum install fontconfig java-17-openjdk-devel wget -y  &>/tmp/jinstall.log
Stat $?
wget --no-check-certificate -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo &>>/tmp/jinstall.log 
Stat $?

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key &>>/tmp/jinstall.log 
Stat $?

yum install jenkins --nogpgcheck -y &>>/tmp/jinstall.log
Stat $?

systemctl enable jenkins  &>>/tmp/jinstall.log 
Stat $?

systemctl start jenkins  &>>/tmp/jinstall.log 
Stat $?

echo -e "\e[32m INSTALLATION SUCCESSFUL\e[0m"

mkdir -p /var/lib/jenkins/.ssh
echo 'Host *
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no' >/var/lib/jenkins/.ssh/config
chown jenkins:jenkins /var/lib/jenkins/.ssh -R
chmod 400 /var/lib/jenkins/.ssh/config
COMMENT



LOG_FILE="/tmp/jinstall.log"

echo "=============================="
echo "Jenkins Installation Started..."
echo "Log: $LOG_FILE"
echo "=============================="

# --- Step 1: Root Check ---
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run as root!"
    exit 1
fi

# --- Step 2: Update System ---
echo "[INFO] Updating system packages..."
dnf update -y &>> "$LOG_FILE"

# --- Step 3: Install Dependencies (Java 17, wget, fontconfig) ---
echo "[INFO] Installing Java 17, wget, and fontconfig..."
dnf install -y fontconfig java-17-openjdk-devel wget git &>> "$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install dependencies. Check $LOG_FILE"
    exit 2
fi

# --- Step 4: Configure Jenkins Repository ---
echo "[INFO] Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo &>> "$LOG_FILE"
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key &>> "$LOG_FILE"

# --- Step 5: Install Jenkins ---
echo "[INFO] Installing Jenkins..."
dnf install -y jenkins &>> "$LOG_FILE"

if [ $? -ne 0 ]; then
    echo "[WARNING] Jenkins repo failed. Trying direct RPM installation..."
    cd /tmp
    wget --no-check-certificate https://pkg.jenkins.io/redhat-stable/jenkins-2.452.2-1.1.noarch.rpm &>> "$LOG_FILE"
    dnf install -y ./jenkins-2.452.2-1.1.noarch.rpm &>> "$LOG_FILE"
    
    if [ $? -ne 0 ]; then
        echo "[ERROR] Jenkins installation failed. Check $LOG_FILE"
        exit 3
    fi
fi

# --- Step 6: Enable and Start Jenkins ---
echo "[INFO] Enabling and starting Jenkins service..."
systemctl enable jenkins &>> "$LOG_FILE"
systemctl start jenkins &>> "$LOG_FILE"

# --- Step 7: Wait for Jenkins to Initialize ---
echo "[INFO] Waiting for Jenkins to initialize..."
sleep 30

# --- Step 8: Firewall Configuration ---
if command -v firewall-cmd &>/dev/null; then
    echo "[INFO] Configuring firewall for Jenkins on port 8080..."
    firewall-cmd --permanent --add-port=8080/tcp &>> "$LOG_FILE"
    firewall-cmd --reload &>> "$LOG_FILE"
fi

# --- Step 9: Configure SSH for Jenkins User ---
echo "[INFO] Setting up SSH config for Jenkins user..."
mkdir -p /var/lib/jenkins/.ssh
cat > /var/lib/jenkins/.ssh/config <<EOF
Host *
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
EOF
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
chmod 400 /var/lib/jenkins/.ssh/config

# --- Step 10: Show Initial Admin Password ---
echo "[INFO] Fetching initial Jenkins admin password..."
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo -e "\n=== Initial Admin Password ==="
    cat /var/lib/jenkins/secrets/initialAdminPassword
    echo -e "\n=============================="
else
    echo "[WARNING] Jenkins password file not found yet. Wait 30s and run:"
    echo "cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

# --- Step 11: Print Access URL ---
IP=$(hostname -I | awk '{print $1}')
echo -e "\n[INFO] Jenkins is running at: http://$IP:8080"

echo -e "\n\033[32mJENKINS INSTALLATION SUCCESSFUL WITH JDK 17!\033[0m"

