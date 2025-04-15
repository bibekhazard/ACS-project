
 ### Ansible Configuration
 
 #### Introduction
 This project demonstrates the deployment and configuration of a web server environment using Ansible on AWS Webserver 3 and 4. 
 It covers both static and dynamic inventory methods, automation of Apache installation, image hosting via Amazon S3, and 
 configuration of Ansible playbooks for seamless remote management. 
 
 #### Install Dependencies
 Install required Python and Ansible packages:
 sudo yum install ansible -y
 sudo yum install python3-boto3 -y
 
 #### Test Connectivity
 ansible -i hosts.txt linux -m ping
 ansible -i hosts_novars.txt linux -m ping
 
 #### Upload Image to S3
 Manually upload an image named `demo.png` to the S3 bucket. This image was used by the web servers.
 
 #### Install Apache Webserver
 ansible linux –m yum –a "name=httpd state=installed" -b
 
 #### Start and enable the httpd service
 ansible linux –m service–a "name=httpd –state=started enabled=yes" -b
 
 #### Debugging
 ansible linux –m service–a "name=httpd –state=started enabled=yes" -b –vvv
 
 #### Run Ansible Playbooks
 Navigate to the Ansible directory and update the S3 bucket name in `s3playbook.yml`:
 cd ~/environment/ansiblefinal/
 
 Download the image from the S3 bucket:
 ansible-playbook s3playbook.yml
 
 Run myplaybook.yml
 ansible-playbook myplaybook.yml
 
 #### For dynamic inventory deploy the web application to the web servers:
 This task demonstrates how to configure and use Ansible Dynamic Inventory with AWS EC2 instances using the aws_ec2 plugin.
 Prerequisites
 Ensure boto3 is installed on your Amazon Linux system:
 sudo yum install python3-boto3 -y
 
 **Step 1:** Create Dynamic Inventory File
 Create a file named aws_ec2.yaml with the following configuration:
 
 plugin: aws_ec2
 regions:
   - us-east-1
 keyed_groups:
   - key: tags.Owner
     prefix: tag
 filters:
   instance-state-name : running
 compose:
   ansible_host: public_ip_address
 
 **Step 2:** Update Ansible Configuration
 
 Edit the Ansible configuration file:
 sudo vi /ansiblefinal/ansible.cfg
 
 Update or add the following lines:
 [inventory]
 enable_plugins = aws_ec2
 [defaults]
 inventory = ./aws_ec2.yaml
 host_key_checking = False
 
 **Step 3:** Verify the Dynamic Inventory
 Run the following command to view the EC2 instances grouped dynamically:
 ansible-playbook -i aws_ec2.yml myplaybook.yml
 