# Logging with Fluentd

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

Edit `fluentd.yaml` on line 196, setting the `REGION` and `CLUSTER_NAME` environment variable values.

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

### Checkpoint:
Congratulations, you've successfully rolled out the like microservice from the monolith and observed the logs in CloudWatch.  If you have time, try to do the CI/CD lab by going to this link: [Lab 5](../Lab5/README.md). Otherwise, please remember to follow the steps  in the **[Workshop Cleanup](../README.md#workshop-cleanup)** to make sure all assets created during the workshop are removed so you do not see unexpected charges after today.

**Go to [Lab 5](../Lab5/README.md)**
**To go [back](../README.md) to main menu**