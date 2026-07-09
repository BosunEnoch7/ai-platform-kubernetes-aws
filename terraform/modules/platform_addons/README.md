# Platform add-ons Terraform module

This module creates AWS-side resources required by Kubernetes platform add-ons.
It does not install Helm charts into the cluster. Argo CD will own add-on
installation in a later phase.

## Current responsibility

- Creates an IRSA role for AWS Load Balancer Controller.
- Attaches IAM permissions needed for the controller to reconcile AWS load
  balancers, target groups, listeners, rules, and load-balancer security groups.
- Outputs a non-secret Helm values object that later phases can pass into the
  controller release.

## Why this belongs outside the app module

The AI inference workload owns application resources such as ECR, its secret
container, and its workload-specific IRSA role. The AWS Load Balancer Controller
is a cluster capability. If the app owned that controller role, deleting or
changing the app could accidentally damage shared networking for other
workloads.

## Security notes

The AWS Load Balancer Controller needs broad read access to networking and load
balancer APIs because it reconciles Kubernetes Ingress and Service objects into
AWS resources. Security-group mutation is constrained to the cluster VPC using
the `ec2:Vpc` condition.

For stricter production environments, review the active upstream AWS Load
Balancer Controller IAM policy during upgrades and add tag-based conditions
around create/delete actions.
