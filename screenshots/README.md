# Screenshots

Save your evidence here while you build the project (README, Part 13):

| File | What to capture | README step |
|------|-----------------|-------------|
| `01-ecr-image.png` | ECR console: repository `kwaku-store` with the `v1` image | 14 |
| `02-eks-cluster.png` | EKS console: `kwaku-store-cluster` Active, node group with 2 nodes | 15-17 |
| `03-kubectl-get-nodes.png` | `kubectl get nodes` showing 2 nodes `Ready` | 17 |
| `04-pods-running.png` | `kubectl get pods -n kwaku-store -o wide` with 3 pods `Running` | 21 |
| `05-website.png` | The store open in your browser through the load balancer URL | 24 |
| `06-self-healing.png` | `kubectl get pods -w`: the deleted pod terminating and a new one becoming ready | 27-28 |
| `07-hpa.png` | `kubectl get hpa -n kwaku-store` during the load test | 33 |
| `08-container-insights.png` | CloudWatch → Container Insights for the cluster | 39 |
| `09-cleanup.png` | `aws eks list-clusters` returning no cluster | 48 |

Crop out your AWS account ID and anything sensitive before committing.
