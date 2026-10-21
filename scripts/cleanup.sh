#!/usr/bin/env bash
# Deletes everything this project created (README Part 14, steps 42-48) in the right order:
# load generator → Service (removes the load balancer) → HPA + Deployment → EKS cluster →
# ECR repository → CloudWatch IAM role → Container Insights log groups.
#   ./scripts/cleanup.sh
set -uo pipefail   # no -e: keep going if something is already gone

AWS_REGION="${AWS_REGION:-eu-west-2}"
CLUSTER_NAME="${CLUSTER_NAME:-kwaku-store-cluster}"
REPO_NAME="${REPO_NAME:-kwaku-store}"
ROLE_NAME="${ROLE_NAME:-KwakuStoreCloudWatchRole}"
K8S_DIR="$(cd "$(dirname "$0")/../k8s" && pwd)"

echo "▶ Step 42-44: Kubernetes resources (the Service deletion removes the AWS load balancer)"
if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null
  kubectl delete -f "$K8S_DIR/load-generator.yaml" --ignore-not-found
  kubectl delete service kwaku-store-service -n kwaku-store --ignore-not-found --wait=true
  kubectl delete -f "$K8S_DIR/hpa.yaml" --ignore-not-found
  kubectl delete deployment kwaku-store -n kwaku-store --ignore-not-found
  kubectl delete namespace kwaku-store --ignore-not-found
  echo "   waiting 60s for AWS to remove the load balancer..."
  sleep 60

  echo "▶ Step 45: EKS cluster, node group and CloudFormation stacks (15-20 minutes)"
  eksctl delete cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --wait
else
  echo "   cluster ${CLUSTER_NAME} not found, skipping"
fi

echo "▶ Step 46: ECR repository and its images"
aws ecr delete-repository --repository-name "$REPO_NAME" --region "$AWS_REGION" --force \
  --query 'repository.repositoryName' --output text 2>/dev/null || echo "   not found, skipping"

echo "▶ Step 47: CloudWatch IAM role"
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  for arn in $(aws iam list-attached-role-policies --role-name "$ROLE_NAME" \
      --query 'AttachedPolicies[].PolicyArn' --output text); do
    aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$arn"
  done
  aws iam delete-role --role-name "$ROLE_NAME" && echo "   deleted ${ROLE_NAME}"
else
  echo "   role not found, skipping"
fi

echo "▶ Container Insights log groups"
for group in $(aws logs describe-log-groups --region "$AWS_REGION" \
    --log-group-name-prefix "/aws/containerinsights/${CLUSTER_NAME}/" \
    --query 'logGroups[].logGroupName' --output text); do
  aws logs delete-log-group --region "$AWS_REGION" --log-group-name "$group" && echo "   deleted ${group}"
done

echo "▶ Step 48: verify"
echo "   EKS clusters:          $(aws eks list-clusters --region "$AWS_REGION" --query 'clusters' --output text)"
echo "   Classic load balancers: $(aws elb describe-load-balancers --region "$AWS_REGION" --query 'length(LoadBalancerDescriptions)' --output text)"
echo "   ALB/NLB load balancers: $(aws elbv2 describe-load-balancers --region "$AWS_REGION" --query 'length(LoadBalancers)' --output text)"
aws cloudformation list-stacks --region "$AWS_REGION" \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE DELETE_FAILED \
  --query "StackSummaries[?contains(StackName, '${CLUSTER_NAME}')].[StackName,StackStatus]" --output table

echo ""
echo "✅ Cleanup finished. Check the AWS Billing dashboard over the next day to confirm nothing is still charging."
