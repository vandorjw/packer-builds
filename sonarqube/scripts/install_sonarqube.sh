# add jessie-backports
echo "deb http://http.debian.net/debian jessie-backports" | sudo tee -a /etc/apt/sources.list.d/jessie-backports.list
sudo apt-get update

# install required libraries
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    postgresql-contrib \
    postgresql-client \
    libpostgresql-jdbc-java \
    unzip

sudo apt-get install -y -t jessie-backports \ 
    openjdk-8-jre-headless \
    openjdk-8-jdk-headless

# download sonarqube and place files under /opt/sonarqube
wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.3.1.zip
unzip sonarqube-6.3.1.zip
sudo mkdir /opt/sonarqube
sudo cp -r sonarqube-6.3.1/* /opt/sonarqube/
rm -r ./sonarqube-6.3.1

# create system user which will run sonarqube
sudo useradd -r -s /bin/false sonarqube -b /opt/sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Generate a random password
SONAR_DB_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Create database and database user
sudo -u postgres psql -c "CREATE ROLE sonar WITH LOGIN PASSWORD '$SONAR_DB_PWD';"
sudo -u postgres psql -c "CREATE DATABASE sonar WITH OWNER sonar;"

# update sonar.properties
echo "sonar.jdbc.url=jdbc:postgresql://localhost/sonar" | sudo tee -a /opt/sonarqube/conf/sonar.properties
echo "sonar.jdbc.username=sonar" | sudo tee -a /opt/sonarqube/conf/sonar.properties
echo "sonar.jdbc.password=$SONAR_DB_PWD" | sudo tee -a /opt/sonarqube/conf/sonar.properties

# use the following systemd service unit
cat << EOF | sudo tee /etc/systemd/system/sonarqube.service > /dev/null
[Unit]
Description=SonarQube
After=network.target network-online.target
Wants=network-online.target

[Service]
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
ExecReload=/opt/sonarqube/bin/linux-x86-64/sonar.sh restart
Type=forking
User=sonarqube

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl start sonarqube.service
sudo systemctl enable sonarqube.service 



