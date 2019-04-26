TF_VERSION := 0.11.13

terraform_${TF_VERSION}_linux_amd64.zip:
	which wget
	which curl
	wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

terraform: terraform_${TF_VERSION}_linux_amd64.zip
	unzip terraform_${TF_VERSION}_linux_amd64.zip
	
check-tf-version: terraform
	./terrafrom version
