#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Update package index and install required dependencies
apt-get update
apt-get install -y libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev make

# Install optional dependencies
apt-get install -y libavcodec-dev libavformat-dev libavutil-dev libswscale-dev
apt-get install -y freerdp2-dev
apt-get install -y libpango1.0-dev
apt-get install -y libssh2-1-dev
apt-get install -y libvncserver-dev
apt-get install -y libssl-dev
apt-get install -y libvorbis-dev
apt-get install -y libwebp-dev

# Download guacamole-server source
wget -O guacamole-server-1.3.0.tar.gz https://apache.org/dyn/closer.lua/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz?action=download
tar -xzf guacamole-server-1.3.0.tar.gz
cd guacamole-server-1.3.0/

# Run configure
./configure --with-init-dir=/etc/init.d

# Run make
make
make install
ldconfig

# Enable the guacd service
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

cd ~

# Install Apache Tomcat https://computingforgeeks.com/install-and-use-guacamole-on-ubuntu/
apt-get install -y openjdk-11-jdk
useradd -m -U -d /opt/tomcat -s /bin/false tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.56/bin/apache-tomcat-9.0.56.tar.gz
mkdir /opt/tomcat
tar -xzf apache-tomcat-9.0.56.tar.gz -C /opt/tomcat
mv /opt/tomcat/apache-tomcat-9.0.56 /opt/tomcat/tomcatapp
chown -R tomcat: /opt/tomcat
chmod +x /opt/tomcat/tomcatapp/bin/*.sh
cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"

Environment="CATALINA_BASE=/opt/tomcat/tomcatapp"
Environment="CATALINA_HOME=/opt/tomcat/tomcatapp"
Environment="CATALINA_PID=/opt/tomcat/tomcatapp/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/tomcatapp/bin/startup.sh
ExecStop=/opt/tomcat/tomcatapp/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tomcat
ufw allow 8080/tcp

# Install guacamole-client
mkdir /etc/guacamole
wget -O ~/guacamole-1.3.0.war https://apache.org/dyn/closer.lua/guacamole/1.3.0/binary/guacamole-1.3.0.war?action=download
mv ~/guacamole-1.3.0.war /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /opt/tomcat/tomcatapp/webapps

echo "GUACAMOLE_HOME=/etc/guacamole" | tee -a /etc/default/tomcat
cat > /etc/guacamole/guacamole.properties << EOF
guacd-hostname: localhost
guacd-port:    4822
user-mapping:    /etc/guacamole/user-mapping.xml
auth-provider:    net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOF
ln -s /etc/guacamole /opt/tomcat/tomcatapp/.guacamole

# Username for Guacamole: msi-gns3
# Password for Guacamole: msi-gns3
cat > /etc/guacamole/user-mapping.xml << EOF
<user-mapping>

    <!-- Per-user authentication and config information -->

    <!-- A user using md5 to hash the password guacadmin user and its md5 hashed password below is used to login to Guacamole Web UI-->

    <authorize username="msi-gns3" password="5692a48bde7b33d96fb6b5c9338db2f9" encoding="md5">
        <!-- VNC connection to Cloud GNS3 desktop -->
        <connection name="Cloud GNS3">
            <protocol>vnc</protocol>
            <param name="hostname">localhost</param>
            <param name="port">5900</param>
            <param name="username">vagrant</param>
            <param name="password">msi-gns3</param>
        </connection>
    </authorize>

</user-mapping>
EOF

systemctl restart tomcat guacd
ufw allow 4822/tcp