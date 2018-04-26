# Terraform Variables
# Customize parameters in this file specific to your deployment.
# Sensitive data (passwords) can be supplied here, or alternatively supplied inline when applying config:
# terraform apply -var 'ddclient_password=PASSWORD' 

# Container image to use

image_name = "clayshek/ddclient-debian-arm"

# DDCLIENT CONFIG
# Credentials for ddclient saved as a Kubernetes Secret
# https://kubernetes.io/docs/concepts/configuration/secret/
# NOTE while K8s secrets saved from yaml require base64 encoding,
# The Terraform K8s Provider handles the encoding, so enter as plain text
# DDClient config reference: https://sourceforge.net/p/ddclient/wiki/usage/

ddclient_username = ""
ddclient_password = ""
ddclient_hostname = "ddnsrecord.example.com"
ddclient_server = "domains.google.com"
ddclient_protocol = "dyndns2"
ddclient_daemon_interval = "1800"

# PERSISTENT VOLUME

nfs_server = "x.x.x.x"
vol_path = "/mnt/path"
storage_capacity = "5Mi"
