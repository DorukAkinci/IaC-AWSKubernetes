resource "aws_eks_cluster" "tf_eks" {
  name     = "${var.kubernetes_cluster_name}"
  role_arn = "${aws_iam_role.tf-eks-master.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.tf-eks-master.id}"]
    subnet_ids         = ["${data.aws_subnet_ids.all.ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.tf-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.tf-cluster-AmazonEKSServicePolicy",
  ]
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encode this
# information and write it into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  tf-eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.tf_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.tf_eks.certificate_authority.0.data}' '${var.kubernetes_cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "tf_eks" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.medium"
  name_prefix                 = "terraform-eks"
  security_groups             = ["${aws_security_group.tf-eks-node.id}"]
  user_data_base64            = "${base64encode(local.tf-eks-node-userdata)}"
  key_name                    = "${var.kubernetes_ec2_keypair_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tf_eks" {
  desired_capacity     = "1"
  launch_configuration = "${aws_launch_configuration.tf_eks.id}"
  max_size             = "1"
  min_size             = "1"
  name                 = "terraform-tf-eks"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.all.ids}"]
 
  tag {
    key                 = "Name"
    value               = "terraform-tf-eks"
    propagate_at_launch = true
  }

    tag {
    key                 = "kubernetes.io/cluster/${var.kubernetes_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.tf-eks-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }

  depends_on = [
    "aws_eks_cluster.tf_eks"
  ]
}

# generate KUBECONFIG as output to save in ~/.kube/config locally
# save the ‚terraform output eks_kubeconfig > config‘, run ‚mv config ~/.kube/config‘ to use it for kubectl
locals {
  kubeconfig = <<KUBECONFIG
 
 
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.tf_eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.tf_eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.kubernetes_cluster_name}"
KUBECONFIG
}
