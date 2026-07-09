# ALB-to-NGINX bridge

This manifest creates the AWS-facing Ingress that the AWS Load Balancer
Controller reconciles into an internet-facing Application Load Balancer.
It also declares the `alb` IngressClass so the class-to-controller contract is
visible in Git.

Traffic flow:

```text
Client
→ AWS Application Load Balancer
→ ingress-nginx-controller Service
→ NGINX Ingress Controller pods
→ application Ingress rules
→ application Service
→ FastAPI pods
```

## Why this exists

The application Helm chart owns app routing with `ingressClassName: nginx`.
This bridge owns AWS-facing routing with `ingressClassName: alb`.

That separation lets the platform team manage cloud entry points while app
teams manage app host/path routing.

## Important annotations

| Annotation | Why it is used |
|---|---|
| `alb.ingress.kubernetes.io/scheme: internet-facing` | Creates a public ALB for the portfolio demo. |
| `alb.ingress.kubernetes.io/target-type: ip` | Sends ALB traffic directly to NGINX controller pod IPs through the Service endpoints. |
| `alb.ingress.kubernetes.io/listen-ports` | Starts with HTTP 80 for a low-friction development baseline. |
| `alb.ingress.kubernetes.io/success-codes: "200-404"` | Proves the ALB can reach NGINX even when NGINX returns a default 404 before app hostnames are configured. |
| `alb.ingress.kubernetes.io/load-balancer-name` | Gives the portfolio ALB a recognizable AWS name. |

## Production hardening

Before using this outside a controlled demo:

- add HTTPS listener and ACM certificate ARN;
- redirect HTTP to HTTPS;
- restrict inbound CIDRs or attach AWS WAF;
- enable ALB access logs to an encrypted S3 bucket;
- decide whether the extra ALB-to-NGINX hop is justified for latency and cost.

## Apply order

1. EKS cluster exists.
2. AWS Load Balancer Controller is installed and healthy.
3. ingress-nginx is installed and healthy.
4. Apply this bridge through Argo CD.
5. Apply the application Ingress that uses `ingressClassName: nginx`.
