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



#!/bin/bash

LOG_FILE="/tmp/jinstall.log"

# --- Step 1: Check root user ---
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] You must run this script as root or with sudo!"
    exit 1
fi

# --- Step 2: Update System ---
echo "[INFO] Updating system packages..."
dnf update -y &>> "$LOG_FILE"

# --- Step 3: Install Dependencies ---
echo "[INFO] Installing Java 17, wget, fontconfig, and git..."
dnf install -y fontconfig java-17-openjdk-devel wget git &>> "$LOG_FILE"

# --- Step 3b: Temporary Fix for RHEL 9 SSL issue ---
if grep -q "Red Hat Enterprise Linux release 9" /etc/redhat-release; then
    echo "[INFO] Detected RHEL 9 - Switching crypto policy to LEGACY for Jenkins SSL..."
    CURRENT_POLICY=$(update-crypto-policies --show)
    update-crypto-policies --set LEGACY &>> "$LOG_FILE"
    REBOOT_REQUIRED=true
else
    REBOOT_REQUIRED=false
fi

# --- Step 4: Configure Jenkins Repository ---
echo "[INFO] Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo &>> "$LOG_FILE"
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key &>> "$LOG_FILE"

# --- Step 5: Install Jenkins (with RPM fallback) ---
echo "[INFO] Installing Jenkins..."
dnf install -y jenkins &>> "$LOG_FILE" || {
    echo "[WARNING] Jenkins repo failed. Trying direct RPM installation..."
    cd /tmp
    wget --no-check-certificate https://pkg.jenkins.io/redhat-stable/jenkins-2.452.2-1.1.noarch.rpm &>> "$LOG_FILE"
    dnf install -y ./jenkins-2.452.2-1.1.noarch.rpm &>> "$LOG_FILE" || {
        echo "[ERROR] Jenkins installation failed. Showing last 20 log lines:"
        tail -20 "$LOG_FILE"
        exit 3
    }
}

# --- Step 6: Enable and Start Jenkins ---
echo "[INFO] Enabling and starting Jenkins service..."
systemctl enable jenkins &>> "$LOG_FILE"
systemctl start jenkins &>> "$LOG_FILE"

# --- Step 7: Restore Crypto Policy ---
if [ "$REBOOT_REQUIRED" = true ]; then
    echo "[INFO] Restoring original crypto policy: $CURRENT_POLICY"
    update-crypto-policies --set "$CURRENT_POLICY" &>> "$LOG_FILE"
fi

# --- Step 8: Verify Jenkins ---
if systemctl is-active --quiet jenkins; then
    echo "[SUCCESS] Jenkins is installed and running!"
    echo "[INFO] Access Jenkins at: http://<your-server-ip>:8080"
    echo "[INFO] Initial admin password:"
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "[ERROR] Jenkins service is not running. Check $LOG_FILE for details."
    exit 4
fi

install_jenkins_rhel9.sh