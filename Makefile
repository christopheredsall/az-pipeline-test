TF_VERSION := 0.11.13
TF_DIR := oci-cluster-terraform
TF_VARS := $(TF_DIR)/terraform.tfvars

all: check-tf-version $(TF_VARS)
terraform_${TF_VERSION}_linux_amd64.zip:
	wget --no-verbose https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

terraform: terraform_${TF_VERSION}_linux_amd64.zip
	unzip terraform_${TF_VERSION}_linux_amd64.zip
	
check-tf-version: terraform
	./terraform version

$(TF_VARS):
	git clone https://github.com/ACRC/oci-cluster-terraform.git
	cd oci-cluster-terraform
	cp $(TF_VARS).example $(TF_VARS)
	sed -i -e '/private_key_path/ s/\/home\/user\/.oci/../' $(TF_VARS)
	cat  $(TF_VARS)
