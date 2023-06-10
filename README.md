# Spot Monitor

This project monitors physical infrastructure from an AWS spot ec2 instance with Uptime Kuma. The instance requests to join a Zero Tier network and then it starts monitoring the worker. If a machine is down, the instance will send a notification to a Telegram channel.

## Installation

Edit the `config.yaml` file and then run:

```bash
make tf-deploy # Create and deploy the monitor
make tf-destroy # Destroy the monitor
```

## Caveats

Uptime Kuma just allows console configuration. To workaround this issue, the ec2 instance keeps a copy of the configuration file in the home directory in order to import it once the instance is already up. Importing the configuration file is a manual process: You need to access the service in port 3001.

Uptime Kuma needs no login since it's just accessible from inside its own network in Zero Tier. 

Uptime Kuma retention logs are not automatically configured. You need to configure them manually.

## Useful commands for this project

```bash
aws kms encrypt --key-id <kms-key-id> --plaintext fileb://ops/terraform/aws/files/uptime_kuma_backup.json --output text --query CiphertextBlob --region <aws-kms-region> > uptime_kuma_backup.base64

sops -e --kms <kms-key-arn> --input-type yaml config.yaml > config.enc.yaml
```

## License

[MIT](LICENSE.txt)