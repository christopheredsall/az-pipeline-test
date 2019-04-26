# az-pipeline-test

[![Build Status](https://dev.azure.com/ce16990/cecinestpasunepipe/_apis/build/status/christopheredsall.az-pipeline-test?branchName=master)](https://dev.azure.com/ce16990/cecinestpasunepipe/_build/latest?definitionId=1&branchName=master)

![Ceci n'est pas un pipe](https://upload.wikimedia.org/wikipedia/en/b/b9/MagrittePipe.jpg)
![CitC Logo](https://cluster-in-the-cloud.readthedocs.io/en/latest/_static/logo.png)

Testing Building a [Cluster in the Cloud](https://cluster-in-the-cloud.readthedocs.io/en/latest/index.html) using Azure Pipelines

You will need to configure in the Azure interface some variables:

Your key file needs to be `base64` encoded in to a single long string, e.g.

```ShellSession
$ cat /home/username/.oci/oci_test_key.pem | base64 --wrap=0
```

Add this as the variable `private_key` and mark the variable as a secret (click the :lock: icon).

You will also need to set

```
tenancy_ocid
user_ocid
fingerprint
compartment_ocid
```
