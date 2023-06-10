#!/bin/sh

# Install Docker and Compose Uptime Kuma

yum install -y docker qrencode
systemctl start docker

mkdir -p ${DOCKER_CONFIG}/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o ${DOCKER_CONFIG}/cli-plugins/docker-compose
chmod +x ${DOCKER_CONFIG}/cli-plugins/docker-compose
setfacl --modify user:ec2-user:rw /var/run/docker.sock

aws s3 cp s3://${S3_BUCKET}/${S3_DC_KEY} /home/ec2-user/${S3_DC_KEY}
docker compose -f /home/ec2-user/${S3_DC_KEY} up -d

# Bring the secrets file, decrypt it and edit uptime_kuma_backup.json

aws s3 cp s3://${S3_BUCKET}/${S3_UK_KEY} /home/ec2-user/${S3_UK_KEY}
aws kms decrypt --ciphertext-blob fileb://<(base64 -d /home/ec2-user/${S3_UK_KEY}) --output text --query Plaintext | base64 -d > /home/ec2-user/uptime_kuma_backup.json

# Install and configure ZeroTier

curl -s https://install.zerotier.com | bash && zerotier-cli join ${ZT_NETWORK}

# AWS SES configuration email

while [[ $(aws ses get-identity-verification-attributes --identities ${EMAIL_ADDRESS} | grep VerificationStatus | awk '{print $2}' | tr -d '"') != "Success" ]]; do
    sleep 5
done

aws s3 cp s3://${S3_BUCKET}/${S3_CE_KEY} /home/ec2-user/${S3_CE_KEY}

export EMAIL_ADDRESS=${EMAIL_ADDRESS}
export subject="BTC Monitor"

envsubst '$EMAIL_ADDRESS,$subject' < /home/ec2-user/${S3_CE_KEY} > /home/ec2-user/email.txt

aws ses send-raw-email --raw-message Data="$(echo -n "$(cat /home/ec2-user/email.txt)" | base64 -w 0)"