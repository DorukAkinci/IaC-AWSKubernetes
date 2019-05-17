variable "vpc_id" {
  description="VPC ID"
  default = "vpc-efd4748a"
}

variable "vpc_region_id" { description = "VPC Region" default="us-west-2" } 

variable "kubernetes_cluster_name" {
  description="EKS Cluster Name"
  default="terraform-cluster"
}

variable "kubernetes_subnet_ids" {
  description="Subnet Ids that you want to use"
  default="subnet-ee6099b7,subnet-ee6099b7"
}

variable "kubernetes_ec2_keypair_name" {
  description="Kubernetes Servers Keypair Name"
  default="kp_goldenkey"
}
