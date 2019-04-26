TF_VERSION := 0.11.13
TF_DIR := oci-cluster-terraform
TF_EXAMPLE := $(TF_DIR)/terraform.tfvars.example

all: check-tf-version oci-cluster-terraform/terraform.tfvars.example

terraform_${TF_VERSION}_linux_amd64.zip:
	wget --no-verbose https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

terraform: terraform_${TF_VERSION}_linux_amd64.zip
	unzip terraform_${TF_VERSION}_linux_amd64.zip
	
check-tf-version: terraform
	./terraform version

$(TF_EXAMPLE):
	git clone https://github.com/ACRC/oci-cluster-terraform.git
