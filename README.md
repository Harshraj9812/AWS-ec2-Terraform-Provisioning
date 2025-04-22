# AWS EC2 Instance Setup with Terraform

This guide provides step-by-step instructions for setting up an AWS EC2 instance using Terraform.

## Step 1: Install AWS CLI

### Debian/Ubuntu Installation
```bash
# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y curl unzip

# Download AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the installer
unzip awscliv2.zip

# Run the install script
sudo ./aws/install

# Verify installation
aws --version

# Clean up downloaded files
rm awscliv2.zip
rm -rf aws
```

### Windows Installation
1. Download AWS CLI MSI installer for Windows (64-bit):
   - Visit: https://awscli.amazonaws.com/AWSCLIV2.msi
   - Double-click the downloaded MSI file to launch the installer

2. Verify Installation:
   ```bash
   aws --version
   ```

### macOS Installation
```bash
# Using Homebrew
brew install awscli

# Verify installation
aws --version
```

## Step 2: Configure AWS CLI

1. Get your AWS credentials from AWS Console:
   - Go to AWS Console → IAM → Users → Your User → Security Credentials
   - Create Access Key if you don't have one

2. Configure AWS CLI:
```bash
aws configure
```
Enter when prompted:
- AWS Access Key ID: [Your Access Key]
- AWS Secret Access Key: [Your Secret Key]
- Default region name: ap-south-1
- Default output format: json

## Step 3: Install Terraform

### Debian/Ubuntu Installation
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package list
sudo apt update

# Install Terraform
sudo apt install terraform

# Verify installation
terraform --version
```

### Windows Installation
1. Download Terraform from: https://www.terraform.io/downloads
2. Extract the ZIP file
3. Add Terraform's path to System Environment Variables
4. Verify installation:
   ```bash
   terraform --version
   ```

### macOS Installation
```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform --version
```

## Step 4: Setup SSH Key Pair

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-ec2

# Set correct permissions
chmod 400 ~/.ssh/terraform-ec2
```

## Step 5: Clone and Run Terraform Configuration

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review the Plan**
   ```bash
   terraform plan
   ```

4. **Apply the Configuration**
   ```bash
   terraform apply
   ```
   Type 'yes' when prompted

## Step 6: Connect to EC2 Instance

After successful creation, connect using:
```bash
ssh -i ~/.ssh/terraform-ec2 ubuntu@<instance-public-ip>
```
Replace `<instance-public-ip>` with your EC2 instance's public IP.

## Configuration Details

This Terraform configuration creates:
1. EC2 instance (t3.micro) with Ubuntu
2. Security Group with rules for:
   - SSH (Port 22)
   - HTTP (Port 80)
   - HTTPS (Port 443)
   - ICMP (Ping)
3. SSH Key Pair for instance access

## Troubleshooting

### Common Issues and Solutions:

1. **AWS CLI Configuration Issues**
   ```bash
   # Verify AWS CLI configuration
   aws sts get-caller-identity
   ```

2. **SSH Connection Issues**
   - Check key permissions: `ls -l ~/.ssh/terraform-ec2`
   - Verify security group allows your IP
   - Confirm instance is running in AWS Console

3. **Terraform State Issues**
   ```bash
   # Reinitialize Terraform
   terraform init -reconfigure
   ```

4. **Package Installation Issues (Debian/Ubuntu)**
   ```bash
   # If you get GPG errors
   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

   # If Terraform installation fails
   sudo apt-get clean
   sudo apt-get update
   sudo apt-get install -y terraform
   ```

## Security Notes

1. The security group allows access from any IP (`0.0.0.0/0`). For production:
   - Restrict SSH access to your IP
   - Limit HTTP/HTTPS access as needed
   - Consider removing ICMP access

2. Keep your SSH private key secure and never commit it to version control

## Clean Up

To avoid unwanted AWS charges, always destroy unused resources:
```bash
terraform destroy
```

## Support

For issues or questions:
1. Check AWS Console for resource status
2. Verify all prerequisites are installed correctly
3. Ensure AWS credentials have necessary permissions
4. Review Terraform logs for errors

---
Make sure to replace `<repository-url>` and `<instance-public-ip>` with actual values.