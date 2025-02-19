# Terraform AWS Infrastructure

This project contains Terraform configurations to set up and manage AWS infrastructure.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS account and credentials configured

## Installation

1. Clone the repository:
    ```sh
    git clone <repository-url>
    cd tf-aws-infra
    ```

2. Initialize Terraform:
    ```sh
    terraform init
    ```



## Setting up AWS CLI and Credentials

1. Refer [this link](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to install AWS CLI in your system

2. Configure the AWS CLI with your access keys:
    ```sh
    aws configure --profile your-profile-name
    ```

    You will be prompted to enter your AWS Access Key ID, Secret Access Key, region, and output format.

3. Create a `terraform.tfvars` file to set your variables:
    ```sh
    touch terraform.tfvars
    ```

4. Add your AWS region and other variable values to `terraform.tfvars`:
    ```hcl
    aws_region = "your-region"
    # any other variables you've declared
    ```

    Use the profile by adding the following to your provider configuration in your Terraform files:
    ```hcl
    provider "aws" {
      profile = "your-profile-name"
      region  = "your-region"
    }
    ```

## Terraform Commands

1. Set up AWS profile to which you want to add your resource(s)
    ```sh
    export AWS_PROFILE=your-profile-name
    ```
2. Format the configuration files:
    ```sh
    terraform fmt
    ```

3. Validate the configuration files:
    ```sh
    terraform validate
    ```

4. Plan the infrastructure changes:
    
    ```sh
    terraform plan -var-file="terraform.tfvars"
    ```

5. Apply the infrastructure changes:
    ```sh
    terraform apply -var-file="terraform.tfvars"
    ```


    
# Danger Zone

Destroy the infrastructure:
    
```sh
terraform destroy
```