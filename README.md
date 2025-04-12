### Deployment Pre-requisites:

1.  **AWS Account:** You need an active AWS account.
2.  **S3 Bucket for Terraform State:** Create an S3 bucket to store Terraform state. The bucket name should be unique globally. Update the S3 backend in both environments.
3.  **SSH Key Pair:** You need an SSH key pair in your AWS region (e.g., `us-east-1`). Replace `"your-ssh-key-name"` in `dev/terraform.tfvars` and `prod/terraform.tfvars` with your key pair name.

### Deployment Process:

1.  **Clone the Repository:** Clone this repository to your local machine or AWS Cloud9 environment.
2.  **Initialize Terraform (for dev network):**
    ```bash
    cd dev/network
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
3.  **Initialize Terraform (for prod network):**
    ```bash
    cd ../../prod/network
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
4.  **Initialize Terraform (for dev instances):**
    ```bash
    cd ../../dev/instances
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
    *   Note the outputs, especially `bastion_public_ip`, `web_server_public_ips`, and `db_server_private_ips`.
5.  **Initialize Terraform (for prod instances):**
    ```bash
    cd ../../prod/instances
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
    *   Note the outputs, especially `prod_vm_private_ips`.
6.  **Initialize Terraform (for dev loadbalancer):**
    ```bash
    cd ../../dev/loadbalancer
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
    *   Note the output `alb_dns_name`. Access the web servers using this DNS name in your browser.
7.  **Initialize Terraform (for VPC Peering - Bonus):**
    ```bash
    cd ../peering
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
    * After applying peering, you will need to manually update the `prod/instances/main.tf` security group rule to allow SSH from the Nonprod VPC CIDR and re-apply `prod/instances`. Or you can use `terraform import` to manage the SG rule and update the rule via terraform.

### Accessing Resources:

*   **Bastion Host:** SSH to the Bastion Host using the `bastion_public_ip` output from `dev/instances`.
    ```bash
    ssh -i "path/to/your/private/key.pem" ec2-user@<bastion_public_ip>
    ```
*   **Web Servers (VM1 & VM2):** Access the web servers via HTTP using the `alb_dns_name` output from `dev/loadbalancer`.
    ```
    http://<alb_dns_name>
    ```
*   **DB Server (VM3 & VM4):** Access the DB server from the web servers in the private subnet. You can SSH into a web server through the Bastion and then connect to the DB server using its private IP (`db_server_private_ips` output).
    ```
    sudo yum install -y postgresql
    psql -h <db_server_private_ip> -p 5432 -U postgres
    ```
*   **Prod VMs (VM5 & VM6):** After VPC peering, you can SSH to the Prod VMs from the Bastion Host. Update the `prod_vm_sg` security group in `prod/instances/main.tf` to allow SSH from the Nonprod VPC CIDR or Bastion SG.

### Cleanup Process:

The cleanup process is the reverse of the deployment. **Destroy resources in reverse order of creation (generally):**

1.  **Destroy Load Balancer (dev):**
    ```bash
    cd dev/loadbalancer
    terraform destroy --auto-approve
    ```
2.  **Destroy Instances (prod):**
    ```bash
    cd ../../prod/instances
    terraform destroy --auto-approve
    ```
3.  **Destroy Instances (dev):**
    ```bash
    cd ../../dev/instances
    terraform destroy --auto-approve
    ```
4.  **Destroy VPC Peering:**
    ```bash
    cd ../../peering
    terraform destroy --auto-approve
    ```
5.  **Destroy Network (prod):**
    ```bash
    cd ../../prod/network
    terraform destroy --auto-approve
    ```
6.  **Destroy Network (dev):**
    ```bash
    cd ../../dev/network
    terraform destroy --auto-approve
    ```

**Important Notes:**

*   Replace placeholder values (e.g., bucket names, key names, your name) with your actual values.
*   Review the security group rules and adjust them according to your security requirements, especially for ingress CIDR blocks.
*   This code provides a basic implementation. You might need to customize it further based on specific requirements or best practices.
*   Always run `terraform plan` before `terraform apply` to review the changes.
*   Be cautious when using `--auto-approve` in production environments.
