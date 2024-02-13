## CIS Benchmark

Center for Internet Security® (CIS) is an organization which provides various benchmark reports and standards regarding the security aspects of computer systems.

Apart from the benchmark reports, CIS releases security hardened VM Images for different cloud vendors, which you can purchase from their market places. In AWS marketplace, such a CIS Hardened AMI would cost approximately $15 per month per EC2 instance in addition to the regular EC2 pricing.

Today, our focus is to build a “CIS Level 1” compliant Linux AMI on AWS for FREE!!

In this example we’ll be using Amazon Linux 2 as our base AMI for the build, which is a CentOS like operating system specifically designed and optimised for Amazon EC2 platform.

Alright… Let’s dive into the implementation in detail.

Prerequisites
(Feel free to skip the step 1 and 2 below if you have already setup AWS CLI on your system)

1. Setup AWS User Access Key and Secret

We assume that you already have an AWS account created and you are able to login to the AWS Console with a user with “Administrator Access” privileges. If not, follow this video to create an IAM user with “Administrator Access” policy.

Let’s create an Access Key ID and a Secret Access Key to your user to programmatically access the AWS API. Follow this document or this video to create the keys.

Once created, copy the keys and keep them with you “securely”. Make sure you do not share them in any public location (like GitHub repositories).

2. Setup AWS CLI

Once the IAM user is created and Access Keys generated, our next step is to setup the AWS CLI. Follow these instructions relevant to your PC’s Operating System and install the AWS CLI.

Once installed, type the following command in the terminal (or command prompt) of your PC to verify the installation.

aws --version
If the tool is correctly installed, you should get an output similar to this.

$ aws --version
aws-cli/2.0.15 Python/3.7.4 Darwin/19.6.0 botocore/2.0.0dev19
Now, let’s configure the AWS CLI tool with the credentials we generated at above Step 1.

Run the following command.

aws configure
Then you will be prompted to enter the downloaded credentials and AWS Region information as follows.

$ aws configure
AWS Access Key ID [None]: <Enter Your Access Key ID Here here>
AWS Secret Access Key [None]: <Enter Your Secret Access Key here> 
Default region name [None]: us-east-1
Default output format [None]: text
Note: In the above example, we use the “us-east-1” as the “Default region name”. Hence the resulting AMIs at the end of this project will be deployed to the “us-east-1” region of your AWS account. If you want them to be specifically deployed to a different region of your choice, make sure you set the correct region when configuring the CLI.

You can find the list of AWS regions with their respective code names here.

Read more about “aws configure” command here.

3. Install Packer

Packer is a simple, yet powerful tool built by Hashicorp to automate the Image Build process for various Cloud and Local VM platforms. We’ll be using Packer as the build tool for our AMI build process. Follow the Packer Install Guide and install Packer on you PC. We recommend to follow the “Manual -> Pre-compiled binary” method which will give you more visibility and control over the installation.

Building the AMI
Setting the environment variables
Clone the following Git repository to your PC, which contains the required Packer Templates and utilities to build the CIS Level 1 compliant AMI.

git clone https://github.com/thilinaba/aws-cis-ami.git
Once downloaded, Open the “variables.json” file inside the root directory for the repository to customize the build configuration to match with your AWS account. The definition of each variable is as follows.

profile: Set the correct AWS CLI profile name, if you are using named profiles. Otherwise keep the value as “default”.

region: Select the correct region code name where you want to build the AMI. You can find the list of available regions and their region codes here.

source_ami: Set the latest available Amazon Linux 2 AMI available to your AWS region. Login to the AWS Launch Instance wizard and choose the correct region to find the AMI ID.


Finding the Source AMI ID from AWS Console
vpc_id: Choose theVPC that you want the Packer to build the AMIs. The default VPC in your AWS account’s given region will be compatible.

subnet_id: Choose a Subnet that you want the Packer to build the AMIs. This must be a public subnet. The default subnet in your AWS account’s given VPC will be compatible.

instance_type: Packer will use an EC2 instance with the type mentioned here to build the AMIs. However, you can use the resulting AMI with any type of instance later. Keep the default “t3.micro” unless there is a specific requirement.

ami_name_prefix: The resulting AMI will be named with this prefix and a timestamp. You can change this to a preferred name or keep it as default.

2. Custom installations & configurations

If you want to install any custom packages to the AMI, you can use the “scripts/install.sh” file to add them.

Eg:

#!/bin/bash
# Add your custom installers and other tasks here.
# Make sure you put them with "sudo" command and add "-y" option for non-interactive mode
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y nginx
This is an optional step. Keep the file unchanged if you don’t have any custom package installations or configurations to be done to the AMI.

3. Validating the templates

Once everything is set, Open up a terminal and navigate to the cloned repository directory. Then run the following command to validate the packer template.

packer validate -var-file=variables.json cis-ami.pkr.hcl
If everything is properly in place, the validate command will give you an “empty output”. If there are errors, the errors will be printed.

4. Running the build

Finally, once everything is configured and verified, run the following command to build the Amazon Linux 2 CIS Level 1 compatible AMI.

packer build  -var-file=variables.json cis-ami.pkr.hcl
This will complete the following actions to complete the build.

Create a temporary EC2 instance in the above specified region within the mentioned VPC & subnet.
Apply the hardening configurations and custom installations to the temporary instance.
Stop the instance and create an AMI from it
Add the specified name and other tags to the AMI
Terminate the temporary instance and other resources created by the Packer build process.
5. Using the hardened AMI

Navigate to the AMIs page of your AWS console and change to the correct region mentioned above in the variables.json to view the newly build AMI. You can launch any number of security hardened instances from any instance type without paying extra for CIS Certified AMIs.

Technical Documentation
If you need a reference to the technical documentation, which includes a detailed explanation of each and every configuration parameter that is used to harden to AMI, Please refer to the README file fo the GitHub repository.

https://github.com/thilinaba/aws-cis-ami

Ending…

If you encounter any issue through out this process, let me know in the comments.
