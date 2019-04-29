# FINAL CLEANUP STEPS

- Delete contents of all ECR repo
- Delete contents of the mythicalmysfits S3 bucket
- cd to this directory `cd /home/ec2-user/environment/sydummit-eksworkshop-2019/workshop-1/script/`
- Open the finalcleanup.sh script and update the ROLE variable to be the name of your EKS nodegroup role
- run `./finalcleanup.sh`
- The EKS cluster can take up to 15 minutes to delete. Wait till the EKS cluster has successfully deleted
- Delete the `eksworkshop` key pair from your EC2 dashboard
- delete the following CloudFormation stacks. [Delete the CloudFormation stack](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html):
  - eksworkshop-codepipeline (if you did lab 5)
  - aws-cloud9-Project-mythical-mysfits-eks-XXXXX (name of your Cloud9 CF stack)
  - mythical-mysfits-eks ( The initial Cloudformation template you created)

**All resources should be successfully deleted now. If they have not, please check "drift" on your Cloudformation stack to figure out what values were different.**
