# Logging with Fluentd

Now lets move the Lab4 directory.
```sh
cd /home/ec2-user/environment/sydummit-eksworkshop-2019/workshop-1/Lab4
```
Find the IAM role associated with the EC2 worker nodes, and assign it to a variable:

```sh
ROLE_NAME=<worker node role>
```

```
My Node ROLE_NAME is: eksctl-mythicalmysfits-nodegroup-NodeInstanceRole-1WI0T4HNSIDXW
```

Attach the policy to the Worker Node Role:

```sh
aws iam put-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker --policy-document file://k8s-logs-policy.json
```

Validate that the policy is attached to the role:

```sh
aws iam get-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker
```

The Fluentd log agent configuration is located in the Kubernetes ConfigMap. Fluentd will be deployed as a DaemonSet, i.e. one pod per worker node. In our case, a 2 node cluster is used and so 4 pods will be shown in the output when we deploy, since we have 2 pods per node.

Edit `fluentd.yaml` on line 196, setting the `REGION` and `CLUSTER_NAME` environment variable values. *Note: the file already has the default region and cluster name we used set. If your cluster name is different, please modify it here*

Apply the configuration:

```sh
kubectl apply -f fluentd.yml
```

Watch for all of the pods to change to running status:

```sh
kubectl get pods -w --namespace=kube-system -l k8s-app=fluentd-cloudwatch
```

We are now ready to check that logs are arriving in CloudWatch Logs.

Select the region that is mentioned in `fluentd.yml` to browse the Cloudwatch Log Group if required.

### How to verify logs are working and also your like service is working
1) Go to Cloudwatch Console.
2) Go to "Logs"
3) Go to the "mythicalmysfits" log group
4) Now before you search for the logs, go to your mythical mysfits webpage and click on the "heart" icon which calls the "like" API. 
5) Now go back to the Cloudwatch console and search the log group for "Like processed". You should see the logs show that message being issued by the "like" container image. 
![Like Processed](images/fluentd-like.png)

**CLEANUP REQUEST: PLEASE you MUST issue these commands whether you plan to continue to the next lab or finish, otherwise our account cleanup scripts won't work.**
Issue the following commands:
```
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/workshop-1/Lab4/fluentd.yml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/likeservice-app.yaml 
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/nolikeservice-app.yaml
kubectl delete -f /home/ec2-user/environment/sydummit-eksworkshop-2019/Kubernetes/micro/mythical-ingress.yaml 
```

### Checkpoint:
Congratulations, you've successfully rolled out the like microservice from the monolith and observed the logs in CloudWatch.  If you have time, try to do the CI/CD lab by going to this link: [Lab 5](../Lab5/README.md). Otherwise, please remember to follow the steps  in the **[Workshop Cleanup](../README.md#workshop-cleanup)** to make sure all assets created during the workshop are removed so you do not see unexpected charges after today.

**Go to [Lab 5](../Lab5/README.md)**
**To go [back](../README.md) to main menu**
