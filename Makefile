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

azure-test.pub:
	ssh-keygen -N ""  -f azure-test

$(TF_VARS): azure-test.pub
	echo ${MY_MAPPED_ENV_VAR}
	ls -l
	cat oci_api_key.pem
	openssl rsa -pubout -outform DER -in oci_api_key.pem | openssl md5 -c
	git clone https://github.com/ACRC/oci-cluster-terraform.git
	cp $(TF_VARS).example $(TF_VARS)
	sed -i -e '/private_key_path/ s/\/home\/user\/.oci/../' $(TF_VARS)
	sed -i -e "/tenancy_ocid/ s/ocid1.tenancy.oc1.../$(TENANCY_OCID)/" $(TF_VARS)
	sed -i -e "/user_ocid/ s/ocid1.user.oc1.../$(USER_OCID)/" $(TF_VARS)
	sed -i -e "/fingerprint/ s/11:22:33:44:55:66:77:88:99:00:aa:bb:cc:dd:ee:ff/$(FINGERPRINT)/" $(TF_VARS)
	sed -i -e "/compartment_ocid/ s/ocid1.compartment.oc1.../$(COMPARTMENT_OCID)/" $(TF_VARS)
	sed -i -e "/ssh_public_key/ r azure-test.pub" $(TF_VARS)
	sed -i -e "/FilesystemAD/ s/1/2/" $(TF_VARS)
	cat  $(TF_VARS)
	cd oci-cluster-terraform \
	  && ../terraform init \
	  && ../terraform validate \
	  && ../terraform plan \
	  && ../terraform apply -auto-approve
	# we need to ignore errors between here and the destroy, so make commands start with a minus
	echo MGMT_IP=$(shell terraform show -no-color oci-cluster-terraform/terraform.tfstate | grep '^ManagementPublicIP' | awk '{print $$3}')
	$(eval MGMT_IP=$(shell terraform show -no-color oci-cluster-terraform/terraform.tfstate | grep 'PublicIP' | awk '{print $$3}'))
	echo "Host mgmt\n\tIdentityFile azure-test\n\tHostname $(MGMT_IP)\n"  
	echo "Host mgmt\n\tIdentityFile azure-test\n\tHostname $(MGMT_IP)\n" > ssh-config
	-cat ssh-config
	-ssh -F ssh-config opc@mgmt  "while [ ! -f /mnt/shared/finalised/mgmt ] ; do sleep 2; done" ## wait for ansible
	-ssh -F ssh-config opc@mgmt  "echo -ne 'VM.Standard2.1:\n  1: 1\n  2: 1\n  3: 1\n' > limits.yaml && ./finish"
	-ssh -F ssh-config opc@mgmt  "sudo mkdir -p /mnt/shared/test && sudo chown opc /mnt/shared/test"
	-ssh -F ssh-config opc@mgmt  'echo -ne "#!/bin/bash\n\nsrun hostname\n" > test.slm'
	-ssh -F ssh-config opc@mgmt "echo vm-standard2-1-ad1-0001 > expected" 
	-ssh -F ssh-config opc@mgmt  "sbatch --chdir=/mnt/shared/test --wait test.slm"
	-ssh -F ssh-config opc@mgmt "diff /mnt/shared/test/slurm-2.out expected" 
	cd oci-cluster-terraform \
	  && ../terraform destroy -auto-approve
