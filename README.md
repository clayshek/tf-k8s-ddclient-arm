# tf-k8s-ddclient-arm

## Summary

<a href="https://www.terraform.io/">Terraform</a> Provisioner for <a href="https://sourceforge.net/p/ddclient/wiki/Home/">DDClient</a> Dynamic DNS update client in a <a href="https://kubernetes.io/">Kubernetes</a> cluster running on ARM architecture / <a href="https://www.raspberrypi.org">Raspberry Pi</a>. Makes use of <a href="https://www.terraform.io/docs/providers/kubernetes/">Terraform Kubernetes Provider</a>. Includes Terraform resource definitions for Kubernetes Secrets (for Dynamic DNS update credentials), and Kubernetes Persistent Volume (for DDClient cache file persistent storage). Functionality mostly similar to deploying using a <a href="https://helm.sh/">Helm</a> chart, but currently no version of Tiller available to run on ARM architecture. This method allows for single-command deployment, with a single variables config file. 

Container based off of Docker image located at <a href="https://hub.docker.com/r/clayshek/ddclient-debian-arm/">https://hub.docker.com/r/clayshek/ddclient-debian-arm/</a>. Runs on top of ARM32v7/Debian:stretch-slim, approx size 84 MB. Containers based off this image configurable via terraform.tfvars and should work for most use-cases, but for deeper configuration needs, custom Docker images can be built and used by modifying image_name parameter in terraform.tfvars.

Some code based off of <a href="https://github.com/steasdal/ddclient-alpine">steasdal/ddclient-alpine</a> & <a href="https://github.com/rycus86/docker-ddclient">rycus86/docker-ddclient</a>

## Requirements

- Working Kubernetes cluster (developed on v1.9) on Raspberry Pi. <a href="https://gist.github.com/alexellis/fdbc90de7691a1b9edb545c17da2d975">Info</a>
- <a href="https://www.terraform.io/downloads.html">Terraform</a> (tested with v0.11.7)
- Terraform must have connectivity to Kubernetes. Either run on K8s master (easiest), or other workstation with properly configured Kube config file and <a href="https://www.terraform.io/docs/providers/kubernetes/guides/getting-started.html#provider-setup">Terraform provider setup</a>.
- Pre-configured NFS share (default) or other Kubernetes supported <a href="https://kubernetes.io/docs/concepts/storage/persistent-volumes/">Persistent Volume</a> for DDclient cache storage. If using other than NFS, customization of main.tf likely required in addition to tfvars file. See <a href="https://www.terraform.io/docs/providers/kubernetes/r/persistent_volume.html">Terraform kubernetes_persistent_volume</a> resource documentation for further details. An alternative, if not using persistent storage, would be to comment out all volume related code in main.tf, but risk (relatively small) chance of being flagged for abuse by DDNS provider due to repeated update attempts after container restarts. 

## Usage

- Clone the repository
- Customize the parameters in the terraform.tfvars file as applicable for provisioning. Includes DDClient <a href="https://sourceforge.net/p/ddclient/wiki/usage/">config</a> as well as Persistent Volume config. See note in terraform.tfvars regarding base64 Secrets encoding differences from native Kubernetes secrets; also blurb on <a href="https://www.terraform.io/docs/state/sensitive-data.html">Terraform Sensitive Data in State</a>.
- Run <code>terraform init</code> (required for first run to pull Kubernetes provider). 
- Apply the configuration:

```
terraform apply
```

- Remove the configuration from Kubernetes:

```
terraform destroy
```

## To-Do

 - [ ] Metrics & Monitoring. 
 - [ ] Change Replication Controller resource to Deployment when supported by the Provider. See <a href="https://github.com/terraform-providers/terraform-provider-kubernetes/issues/3">Git Issue</a>
 - [ ] Use envFrom for mapping Config Map to environment variables, when supported by Provider. See <a href="https://github.com/terraform-providers/terraform-provider-kubernetes/issues/78">Git Issue</a>)
 - [ ] Evaluate <a href="https://www.vaultproject.io/">Vault</a> for Secrets
 - [ ] Evaluate other Storage options. Possibly <a href="https://rook.io/">Rook</a>? <a href="https://ceph.com/">Ceph</a>?
 - [ ] Ultimately evaluate workload for Function as a Service, potentially <a href="https://github.com/openfaas">OpenFaaS</a> 

## License

This is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
