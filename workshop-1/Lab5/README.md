# Continuous Deployment with EKS

**NOTE: You'll need your own github account and also ability to generate a github token in order to do this lab**

In this lab, we build a CI/CD pipeline using AWS CodePipeline. The CI/CD pipeline will deploy a sample Kubernetes service. Committing a code change to the GitHub repository triggers the automated delivery of this change to the cluster.

## Create IAM Role for CodeBuild

CodeBuild requires an IAM role capable of interacting with an EKS cluster.

This script creates an IAM role and adds an inline policy. This Role is used in the CodeBuild stage of CodePipeline to interact with EKS using `kubectl`. Change your directory on the AWS Cloud9 IDE to *workshop-1/Lab5 directory*. 

```sh
./create-iam-role.sh
```

## Add IAM role to `aws-auth` ConfigMap

This script patches `aws-auth` ConfigMap, adding the IAM role we created in the previous step. This allows `kubectl` in the CodeBuild stage of the pipeline to interact with EKS.

```sh
./patch-aws-auth.sh
```

You can manually edit the ConfigMap with this command (but we have already modified so no need):

```sh
kubectl edit -n kube-system configmap/aws-auth
```

## Fork Github Repository

We must [fork](https://help.github.com/articles/fork-a-repo/) the sample Kubernetes service so that we will be able modify the repository and trigger builds.

Login to GitHub and fork the sample service to your own account:

<https://github.com/kmhabib/sydsummit-eks-cicd>

Once the repo is forked, you can view it in your your [GitHub repositories](https://github.com).

## Github Access Token

In order for CodePipeline to receive callbacks from GitHub, we need to generate a personal access token.

Create a new personal access token here: <https://github.com/settings/tokens/new>

Enter a value for **Token description**, check the **repo** permission scope and scroll down and click the **Generate token button**.

Copy the personal access token and save it in a secure place.

## CodePipeline

*NOTE: If your EKS cluster name is not `mythicalmysfits`, ensure you update the name for that parameter. In our case, it is `mythicalmysfits`*

Click on one of the **Deploy to AWS** icons below to region to stand up the core workshop infrastructure.

| Region | Launch Template |
| ------------ | ------------- | 
**Oregon** (us-west-2) | [![Launch Mythical Mysfits Stack into Oregon with CloudFormation](../images/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=eksworkshop-codepipeline&templateURL=https://s3-us-west-2.amazonaws.com/syd-eksworkshop-2019/codepipeline.yaml)  


Enter your Github username and personal access token you create in the previous step. 

Wait for the status to change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE` before moving on to the next step.

Open [CodePipeline in the Management Console](https://console.aws.amazon.com/codesuite/codepipeline/pipelines). You will see a CodePipeline that starts with **eks-workshop-codepipeline**.
Click this link to view the details.

Once you are on the detail page for the specific CodePipeline, you can see the status along with a links to the build details. If you click on the **details** link in the build/deploy stage, you can see the output from the CodeBuild process.

To view the status of the Kubernetes deployment:

```sh
kubectl describe deployment hello-k8s
```

For the status of the service, run the following command:

```sh
kubectl describe service hello-k8s
```

Once the service is built and delivered, we can run the following command to get the Elastic Load Balancer (ELB) endpoint and open it in a browser. If the message is not updated immediately, give Kubernetes some time to deploy the change.

```sh
kubectl get services hello-k8s -o wide
```

This service was configured with a [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/) so, an AWS [Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) is launched by EKS for the service. The `EXTERNAL-IP` column contains a value that ends with `elb.amazonaws.com` - the full value is the DNS address. Copy this DNS address and paste it on the browser (*ensure codepipeline is completely deployed and the status of the ELB targets is `InService`*). 

## Trigger a New Deployment

Open your AWS Console and keep your browser open to where your Codepipeline is configured. Open GitHub and select the forked repository with the name `sydsummit-eks-cicd`.

Click on the `main.go` file and then click on the edit button, which looks like a pencil.

Change the text where it says `Hello World` to whatever you want, add a commit message and then click the **Commit changes** button.

You should leave the master branch selected.

After you modify and commit your change in GitHub, in approximately one minute you will see a new build triggered in CodePipeline. 

Confirm the update by browsing the ELB URL you used previously.

**CONGRATULATIONS: You have successfully taken a sample code and deployed it on your EKS cluster using AWS CodePipeline and AWS CodeBuild**

## Clean Up

1. Delete the ECR repository that was created for this image.

1. Empty and then delete the S3 bucket used by CodeBuild for build artifacts (bucket name starts with `eksworkshop-codepipeline`). First, select the bucket, then empty the bucket and finally delete the bucket.

1. Delete the CloudFormation stack in the AWS Management Console.

1. Delete the IAM role created for CodeBuild to permit changes to the EKS cluster, along with the the Kubernetes deployment and service:

    ```sh
    ./cleanup.sh
    ```
*Note: Parts of this lab was taken from linuxacademy's [EKS course](https://github.com/linuxacademy/eks-deep-dive-2019/tree/master/4-2-Continuous-Deployment)*

**GREAT WORK! We hope you enjoyed the lab. To go [back](../README.md) to main menu**

-----
## FINAL Workshop Cleanup

This is really important because if you leave stuff running in your account, it will continue to generate charges.  Certain things were created by CloudFormation and certain things were created manually throughout the workshop.  
**Please follow the steps listed  [*Final Cleanup*](finalcleanup.md)**
