# Terraform Kubernetes provisioner for DDClient on ARM (Raspberry Pi).
# Uses Kubernetes TF Provider (https://www.terraform.io/docs/providers/kubernetes/index.html)
# Resources provisioned: Secret, Config Map, Persistent Volume, PV Claim, Replication Controller

# Provider setup: https://www.terraform.io/docs/providers/kubernetes/guides/getting-started.html#provider-setup

provider "kubernetes" {}

# SECRET - DDCLIENT AUTH CREDS
# Set Kubernetes secret for ddclient credentials

resource "kubernetes_secret" "ddclient-auth" {
  metadata {
    name = "ddclient-auth"
  }

  data {
    username = "${var.ddclient_username}"
    password = "${var.ddclient_password}"
  }

  type = "Opaque"
}

# CONFIG MAP - ENV VARIABLES

resource "kubernetes_config_map" "ddclient-config" {
  metadata {
    name = "ddclient-config"
  }

  data {
    ddclient_hostname = "${var.ddclient_hostname}"
    ddclient_server = "${var.ddclient_server}"
    ddclient_protocol = "${var.ddclient_protocol}"
    ddclient_daemon_interval = "${var.ddclient_daemon_interval}"
  }
}


# PERSISTENT VOLUME
# Coded here for NFS, but can be modified for other supported K8s persistent volume types.
# See https://www.terraform.io/docs/providers/kubernetes/r/persistent_volume.html


resource "kubernetes_persistent_volume" "ddclient_pv" {
    metadata {
        name = "ddclient-pv"
    }
    spec {
        capacity {
            storage = "${var.storage_capacity}"
        }
        access_modes = ["ReadWriteMany"]
        storage_class_name = "ddclient"
        persistent_volume_source {
            nfs {
                path = "${var.vol_path}"
                server = "${var.nfs_server}"
            }
        }
    }
}

# PERSISTENT VOLUME CLAIM

resource "kubernetes_persistent_volume_claim" "ddclient-pv-claim" {
  metadata {
    name = "ddclient-pv-claim"
    labels {
      app = "ddclient"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "${var.storage_capacity}"
      }
    }
    volume_name = "ddclient-pv"
    storage_class_name = "ddclient"
  }
}

# REPLICATION CONTROLLER
# Will replace with Deployment when TF K8s Provider allows it
# See https://github.com/terraform-providers/terraform-provider-kubernetes/issues/3

resource "kubernetes_replication_controller" "ddclient" {
  metadata {
    name = "ddclient"
    labels {
      app = "ddclient"
    }
  }

  spec {
    selector {
      app = "ddclient"
    }
    replicas = 1
    template {
      container {
        image = "${var.image_name}"
        name  = "ddclient"

        env {
          name = "DDNS_USERNAME"
          value_from {
            secret_key_ref {
              name = "ddclient-auth"
              key = "username"
            }
          }
        }
        env {
          name = "DDNS_PASSWORD"
          value_from {
            secret_key_ref {
              name = "ddclient-auth"
              key = "password"
            }
          }
        }

        # Below should use envFrom when provider allows. 
        # See https://github.com/terraform-providers/terraform-provider-kubernetes/issues/78
        env {
          name = "DDNS_HOSTNAME"
          value_from {
            config_map_key_ref {
              name = "ddclient-config"
              key = "ddclient_hostname"
            }
          }
        }
        env {
          name = "DDNS_SERVER"
          value_from {
            config_map_key_ref {
              name = "ddclient-config"
              key = "ddclient_server"
            }
          }
        }        
        env {
          name = "DDNS_PROTOCOL"
          value_from {
            config_map_key_ref {
              name = "ddclient-config"
              key = "ddclient_protocol"
            }
          }
        }
        env {
          name = "DDNS_DAEMON_INTERVAL"
          value_from {
            config_map_key_ref {
              name = "ddclient-config"
              key = "ddclient_daemon_interval"
            }
          }
        }

        volume_mount {
          name = "ddclient-pvc"
          mount_path = "/var/cache/ddclient"
        }
      }

      volume {
        name = "ddclient-pvc"
        persistent_volume_claim {
          claim_name = "ddclient-pv-claim"
        }
      }

    }
  }
}
