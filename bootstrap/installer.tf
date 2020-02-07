resource "null_resource" "installer_folder" {
  provisioner "local-exec" {
    command = "mkdir -p installer_files"
  }

  provisioner "local-exec" {
    command     = "rm -r ./*"
    working_dir = "installer_files/"
  }
}

resource "null_resource" "ocp_installer" {
  provisioner "local-exec" {
    command     = <<EOT
            case $(uname -s) in
                "Darwin" ) 
                    wget -r -l1 -nd -np -e robots=off "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${var.openshift_version}/" -A "openshift-install-mac-*.tar.gz"
                ;;
                "Linux" )
                    wget -r -l1 -nd -np -e robots=off "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${var.openshift_version}/" -A "openshift-install-linux-*.tar.gz"
                ;;
            esac
        EOT
    working_dir = "installer_files/"
  }

  provisioner "local-exec" {
    command     = "tar xzvf openshift-install*.tar.gz"
    working_dir = "installer_files/"
  }

  provisioner "local-exec" {
    command     = "rm -f README.md"
    working_dir = "installer_files/"
  }
}

resource "null_resource" "ocp_client" {
  provisioner "local-exec" {
    command     = <<EOT
            case $(uname -s) in
                "Darwin" ) 
                    wget -r -l1 -nd -np -e robots=off "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${var.openshift_version}/" -A "openshift-client-mac-*.tar.gz"
                ;;
                "Linux" )
                    wget -r -l1 -nd -np -e robots=off "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${var.openshift_version}/" -A "openshift-client-linux-*.tar.gz"
                ;;
            esac
        EOT
    working_dir = "installer_files/"
  }

  provisioner "local-exec" {
    command     = "tar xzvf openshift-client*.tar.gz"
    working_dir = "installer_files/"
  }

  provisioner "local-exec" {
    command     = "rm -f README.md"
    working_dir = "installer_files/"
  }
}

resource "local_file" "install_config" {
  content  = <<EOF
apiVersion: v1
baseDomain: ${var.domain}
compute:
- hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  name: ${var.cluster_name}
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineCIDR: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: ${var.region}
pullSecret: '{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K21heGZsaW50b2ZmMXdsczFqYXVrem5rajFzdHpiOHVpcW9hcnk0OkNONU9RVzlONUZQNzVTS0JRMUNGTDIzVlpIUzdGNDVGUklaVDUxN0RCU09EOEk1WkIyTlJBNks0WklBRUpWWjM=","email":"max.flintoff@ibm.com"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K21heGZsaW50b2ZmMXdsczFqYXVrem5rajFzdHpiOHVpcW9hcnk0OkNONU9RVzlONUZQNzVTS0JRMUNGTDIzVlpIUzdGNDVGUklaVDUxN0RCU09EOEk1WkIyTlJBNks0WklBRUpWWjM=","email":"max.flintoff@ibm.com"},"registry.connect.redhat.com":{"auth":"NTMwNjk0NzN8dWhjLTFXTFMxSkFVa1pOS0oxU3RaQjhVSVFvYVJZNDpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlPREZsWXpBM05ETTFNV0UwTXpBeU9UQm1Oek5tTTJZMU1URTVOVGxtTmlKOS51UGdtdWk2Z3B4WFBEekxXSlJ1UUxwNk16T2lWY3dqdzNrYXJXc2MxbVpMZHlaaEpuNXJsU3hKNmZNRkFCMHZHQ3VtZ1JtaE5FQjZSM2R4bDBnRWdKVXlwbjBES1AyWG5POUtBSllPd3RsSUJFQ2tpMlpncVhabEVaR1hzdkFMcTA0ZnJXNEpFcTF5ajUwSVN0bU9ueGphNFNyd1UxWlBUUC1kTkdpZk5BNWNOQ1lfYlkyQW1xN0NXU2V2ZWtZa2FNaDZHN3pFOXRMNGJRYVBxbkFSNXZpRFpTaVppWG5qb3NOVUhuMktRbUhjMWFuZ1M1RDZyMmZfZ1dkVTBFdldlTzAzM21ablYxbFRSTTdQSV8zTmVsYjl0MTBFU1FjY3ZKbGhQdk9ReEl3Q0MxTmZIQmtGa19WWDRxVjhmNnRaQVB3ejI2WS1kclh2Vmc1ZGRJT1RwNjBDejh1OGJlUERianJRU3NqZjZKeDB6ZFZrRlItQTdvRC1oTmMtekxSZU5HSU55ZmF5blVUZF9TWTc2TEJMUV9VZjJjUjYxWEtaQ2puQmJBVmRSb2NfTTFRd2lJTUdBNEhMXzRQYWZfWVR3eEVnZnZZSGhQOTJFOUtFZjktX2pMZlBVMkx2b2VKb09xQlFLdzRlamZGMnZsUVNkSXhNSDdFcDJQY3ZXMHRWM1d5RVRUWmp0WWE3aW5mdUp5V3ZnX3kxbXpKX2RFVFNkMVc0S1NsWWJFejVyajdOX3NORmxSMUpnUEN2RTNLUnlaRm1mN1lXeWJVZDJCRnZjblhPT2FKaDVPRkxnRXd1R2hlZF9MY3g2di02V0NLa0QzT2dOdGdaNnpwQ1ppMVE0THJTMUZuLXJ5TXNzVG9PdGUxS0pMY1kzVWxYWWtfOTY0TFdBLUpIOFEyWQ==","email":"max.flintoff@ibm.com"},"registry.redhat.io":{"auth":"NTMwNjk0NzN8dWhjLTFXTFMxSkFVa1pOS0oxU3RaQjhVSVFvYVJZNDpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlPREZsWXpBM05ETTFNV0UwTXpBeU9UQm1Oek5tTTJZMU1URTVOVGxtTmlKOS51UGdtdWk2Z3B4WFBEekxXSlJ1UUxwNk16T2lWY3dqdzNrYXJXc2MxbVpMZHlaaEpuNXJsU3hKNmZNRkFCMHZHQ3VtZ1JtaE5FQjZSM2R4bDBnRWdKVXlwbjBES1AyWG5POUtBSllPd3RsSUJFQ2tpMlpncVhabEVaR1hzdkFMcTA0ZnJXNEpFcTF5ajUwSVN0bU9ueGphNFNyd1UxWlBUUC1kTkdpZk5BNWNOQ1lfYlkyQW1xN0NXU2V2ZWtZa2FNaDZHN3pFOXRMNGJRYVBxbkFSNXZpRFpTaVppWG5qb3NOVUhuMktRbUhjMWFuZ1M1RDZyMmZfZ1dkVTBFdldlTzAzM21ablYxbFRSTTdQSV8zTmVsYjl0MTBFU1FjY3ZKbGhQdk9ReEl3Q0MxTmZIQmtGa19WWDRxVjhmNnRaQVB3ejI2WS1kclh2Vmc1ZGRJT1RwNjBDejh1OGJlUERianJRU3NqZjZKeDB6ZFZrRlItQTdvRC1oTmMtekxSZU5HSU55ZmF5blVUZF9TWTc2TEJMUV9VZjJjUjYxWEtaQ2puQmJBVmRSb2NfTTFRd2lJTUdBNEhMXzRQYWZfWVR3eEVnZnZZSGhQOTJFOUtFZjktX2pMZlBVMkx2b2VKb09xQlFLdzRlamZGMnZsUVNkSXhNSDdFcDJQY3ZXMHRWM1d5RVRUWmp0WWE3aW5mdUp5V3ZnX3kxbXpKX2RFVFNkMVc0S1NsWWJFejVyajdOX3NORmxSMUpnUEN2RTNLUnlaRm1mN1lXeWJVZDJCRnZjblhPT2FKaDVPRkxnRXd1R2hlZF9MY3g2di02V0NLa0QzT2dOdGdaNnpwQ1ppMVE0THJTMUZuLXJ5TXNzVG9PdGUxS0pMY1kzVWxYWWtfOTY0TFdBLUpIOFEyWQ==","email":"max.flintoff@ibm.com"}}}'
sshKey: |
  ${var.ssh_key.public_key}
  EOF
  filename = "${path.module}/installer_files/install-config.yaml"
}