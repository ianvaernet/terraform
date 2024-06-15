# Terraform

1. Install Terraform from [here](https://developer.hashicorp.com/terraform/install)
2. Move the binary to a directory in the PATH
3. cd IaC/dev
4. Run `set AWS_PROFILE=profile_name` in Windows or `export AWS_PROFILE=profile_name` in Linux to set the AWS profile to use
5. Run `terraform init` to initialize the backend
6. Run `terraform apply` to build the infrastructure
