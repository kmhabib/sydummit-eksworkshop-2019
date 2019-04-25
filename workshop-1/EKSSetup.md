---
## Create an IAM role for your Workspace
---
1. Follow [this deep link to create an IAM role with Administrator access.](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess)
1. Confirm that **AWS service** and **EC2** are selected, then click **Next** to view permissions.
1. Confirm that **AdministratorAccess** is checked, then click **Next** to review.
1. Enter **eksworkshop-admin** for the Name, and select **Create Role**
![createrole](/images/createrole.png)

---
## Attach the IAM role to your Workspace
---

1. Follow [this deep link to find your Cloud9 EC2 instance](https://console.aws.amazon.com/ec2/v2/home?#Instances:tag:Name=aws-cloud9-Project-mythical-mysfits-fargate-*;sort=desc:launchTime)
1. Select the instance, then choose **Actions / Instance Settings / Attach/Replace IAM Role**
![c9instancerole](/images/c9instancerole.png)
1. Choose **eksworkshop-admin** from the **IAM Role** drop down, and select **Apply**
![c9attachrole](/images/c9attachrole.png)


---
## Update IAM settings for your Workspace
---

{{% notice info %}}
Cloud9 normally manages IAM credentials dynamically. This isn't currently compatible with
the aws-iam-authenticator plugin, so we will disable it and rely on the IAM role instead.
{{% /notice %}}

- Return to your workspace and click the sprocket, or launch a new tab to open the Preferences tab
- Select **AWS SETTINGS**
- Turn off **AWS managed temporary credentials**
- Close the Preferences tab
![c9disableiam](/images/c9disableiam.png)

- To ensure temporary credentials aren't already in place we will also remove
any existing credentials file:
```
rm -vf ${HOME}/.aws/credentials
```

- We should configure our aws cli with our current region as default:
```
sudo yum install jq
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```

### Validate the IAM role

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

First, get the IAM role name from the AWS CLI.
```bash
INSTANCE_PROFILE_NAME=`basename $(aws ec2 describe-instances --filters Name=tag:Name,Values=aws-cloud9-${C9_PROJECT}-${C9_PID} | jq -r '.Reservations[0].Instances[0].IamInstanceProfile.Arn' | awk -F "/" "{print $2}")`
aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --query "InstanceProfile.Roles[0].RoleName" --output text
```

The output is the role name.

```output
eksworkshop-admin
or
modernizer-workshop-cl9
```

Compare that with the result of

```bash
aws sts get-caller-identity
```

#### VALID

If the _Arn_ contains the role name from above and an Instance ID, you may proceed.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
or
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/modernizer-workshop-cl9/i-01234567890abcdef"
}
```

#### INVALID

If the _Arn contains `TeamRole`, `MasterRole`, or does not match the role name, <span style="color: red;">**DO NOT PROCEED**</span>. Go back and confirm the steps on this page.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/TeamRole/MasterRole"
}
```


---
## Install Kubernetes Tools
---

Amazon EKS clusters require kubectl and kubelet binaries and the aws-iam-authenticator
binary to allow IAM authentication for your Kubernetes cluster.

{{% notice tip %}}
In this workshop we will give you the commands to download the Linux
binaries. If you are running Mac OSX / Windows, please [see the official EKS docs
for the download links.](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
{{% /notice %}}

#### Create the default ~/.kube directory for storing kubectl configuration
```
mkdir -p ~/.kube
```

#### Install kubectl
```
sudo curl --silent --location -o /usr/local/bin/kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/kubectl"
sudo chmod +x /usr/local/bin/kubectl
```

#### Install AWS IAM Authenticator
```
go get -u -v github.com/kubernetes-sigs/aws-iam-authenticator/cmd/aws-iam-authenticator
sudo mv ~/go/bin/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
```

#### Verify the binaries
```
kubectl version --short --client
aws-iam-authenticator help
```

#### Install eksctl

For this module, we need to download the [eksctl](https://eksctl.io/) binary:
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

```

Confirm the eksctl command works:
```
eksctl version
```
---
## Create an SSH key
---

{{% notice info %}}
Starting from here, when you see command to be entered such as below, you will enter these commands into Cloud9 IDE. You can use the **Copy to clipboard** feature (right hand upper corner) to simply copy and paste into Cloud9. In order to paste, you can use Ctrl + V for Windows or Command + V for Mac.
{{% /notice %}}

Please run this command to generate SSH Key in Cloud9. This key will be used on the worker node instances to allow ssh access if necessary.

```bash
ssh-keygen
```

{{% notice tip %}}
Press `enter` 3 times to take the default choices
{{% /notice %}}

Upload the public key to your EC2 region:

```bash
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub
```

---
## Launch an EKS Cluster
---

```
eksctl create cluster --full-ecr-access --name=mythicalmysfits
```



You can expect to see an output like the one below.
```
eksctl create cluster --full-ecr-access --name=mythicalmysfits
2018-08-27T21:36:50Z [ℹ]  setting availability zones to [us-west-2c us-west-2b us-west-2a]
2018-08-27T21:36:50Z [ℹ]  importing SSH public key "/home/ec2-user/.ssh/eks-key.pub" as "eksctl-mythicalmysfits-20:bc:c5:14:ab:c1:6b:92:10:e5:92:c0:2a:9e:07:37"
2018-08-27T21:36:50Z [ℹ]  creating EKS cluster "mythicalmysfits" in "us-west-2" region
2018-08-27T21:36:50Z [ℹ]  creating VPC stack "EKS-mythicalmysfits-VPC"
2018-08-27T21:36:50Z [ℹ]  creating ServiceRole stack "EKS-mythicalmysfits-ServiceRole"
2018-08-27T21:37:31Z [✔]  created ServiceRole stack "EKS-mythicalmysfits-ServiceRole"
2018-08-27T21:37:51Z [✔]  created VPC stack "EKS-mythicalmysfits-VPC"
2018-08-27T21:37:51Z [ℹ]  creating control plane "mythicalmysfits"
....
```
