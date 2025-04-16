### Deployment Pre-requisites:

1.  **AWS Account:** You need an active AWS account.
2.  **S3 Bucket for Terraform State:** Create an S3 bucket to store Terraform state. The bucket name should be unique globally. Update the S3 backend in all  environments(backend.tf).
3.  **SSH Key Pair:** You need an SSH key pair in your AWS region (e.g., `us-east-1`). Replace `"your-ssh-key-name"` in `environment/prod/variable.tf` with your key pair name.

### Deployment Process:

1.  **Clone the Repository:** Clone this repository to your local machine or AWS Cloud9 environment.
2.  **Initialize Terraform (for dev ):**
    ```bash
    cd terraform/environment/dev
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
3.  **Initialize Terraform (for prod ):**
    ```bash
    cd terraform/environment/prod
    terraform init
    terraform plan
    terraform apply --auto-approve
    ```
4.  **Initialize Terraform (for staging):**
    ```bash
    cd terraform/environment/staging
    terraform init
    terraform plan
    terraform apply --auto-approve
    
    *   Note the outputs, especially `bastion_public_ip`, `web_server_public_ips`, and `db_server_private_ips`.


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
*   **Prod VMs (VM5 & VM6):**  you can SSH to the Prod VMs from the Bastion Host. Update the `prod_vm_sg` security group in `prod/instances/main.tf` to allow SSH from the Nonprod VPC CIDR or Bastion SG.

### Cleanup Process:

The cleanup process is the reverse of the deployment. **Destroy resources in reverse order of creation (generally):**

1.  **Destroy  (dev):**
    ```bash
        cd terraform/environment/dev
    terraform destroy --auto-approve
    ```
2.  **Destroy  (prod):**
    ```bash
    cd ../environment/prod/
    terraform destroy --auto-approve
    ```
3.  **Destroy (staging):**
    ```bash
    cd ../../dev/staging
    terraform destroy --auto-approve
    ```


**Important Notes:**

*   Replace placeholder values (e.g., bucket names, key names, your name) with your actual values.
*   Review the security group rules and adjust them according to your security requirements, especially for ingress CIDR blocks.
*   This code provides a basic implementation. You might need to customize it further based on specific requirements or best practices.
*   Always run `terraform plan` before `terraform apply` to review the changes.
*   Be cautious when using `--auto-approve` in production environment.
