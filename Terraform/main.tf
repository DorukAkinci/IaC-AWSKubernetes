provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.kubernetes_cluster_name} | jq -r -c .status"]
}

provider "kubernetes" {
  host                   = "${aws_eks_cluster.tf_eks.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.tf_eks.certificate_authority.0.data)}"
  token                  = "${data.external.aws_iam_authenticator.result.token}"
  load_config_file       = false
  version                = "~> 1.5"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${var.vpc_id}"
}

# Setup data source to get amazon-provided AMI for EKS nodes
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}
