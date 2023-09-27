# tf-kiam

This terraform creates the necessary AWS objects to accompany a kiam installation within a Kubernetes cluster.

The defaults are set to function well for a [Tanzu Kubernetes Grid](https://tanzu.vmware.com/kubernetes-grid) Management Cluster on AWS.
See `config.tf` to set provider region, control-plane node role, and kiam role naming options.

First, the code allows the Kubernetes Control Plane Nodes' AWS Role to assume the [kiam](https://github.com/uswitch/kiam) server Role.
The kiam server Role can then assume other AWS Roles on behalf of annotated Kubernetes Pods.

Two granular roles named under the `kiam_role_domain` are then created for [external-dns](https://github.com/kubernetes-sigs/external-dns)
and [cert-manager](https://cert-manager.io/) to manage DNS records and perform DNS-01 ACME challenges for TLS certificates.

This allows secure ingress with nice DNS names to be setup within Kubernetes.

Note: the kiam project authors consider kiam in maintenance-mode in favor of AWS's [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).
Kiam is used here for its simplicity and low AWS privilege requirements.
Setting up IRSA on self-hosted AWS clusters involves modifying kube-apiserver flags and creating additional, more privileged AWS resources.
