TF_VERSION := 0.11.13

all: check-tf-version oci-cluster-terraform/terraform.tfvars.example

terraform_${TF_VERSION}_linux_amd64.zip:
	wget --no-verbose https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

terraform: terraform_${TF_VERSION}_linux_amd64.zip
	unzip terraform_${TF_VERSION}_linux_amd64.zip
	
check-tf-version: terraform
	./terraform version
	/usr/bin/env
	echo ${oci_api_key.pem}

oci-cluster-terraform/terraform.tfvars.example:
	git clone https://github.com/ACRC/oci-cluster-terraform.git
