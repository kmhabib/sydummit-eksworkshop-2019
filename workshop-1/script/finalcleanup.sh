#!/usr/bin/env bash

# Fill the role for nodegroup. looks like eksctl-mythicalmysfits-nodegroup-NodeInstanceRole-1TLRKSZC5S36X
ROLE='YOUR_ROLENAME_FOR_EKS_NODEGROUP'

aws iam delete-role-policy --role-name EKSDeepDiveCodeBuildKubectlRole --policy-name eks-describe
aws iam delete-role --role-name EKSDeepDiveCodeBuildKubectlRole
kubectl delete deployments hello-k8s
kubectl delete services hello-k8s
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/mono/monolith-app.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/likeservice-app.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/nolikeservice-app.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/mythical-ingress.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/alb-ingress-controller.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.0.0/docs/examples/rbac-role.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/workshop-1/Lab4/fluentd.yml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/likeservice-app.yaml 
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/nolikeservice-app.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/mythical-ingress.yaml 


aws iam delete-role-policy --role-name $ROLE --policy-name Logs-Policy-For-Worker
aws iam delete-role-policy --role-name $ROLE --policy-name ingress-ddb

eksctl delete cluster --name=mythicalmysfits


